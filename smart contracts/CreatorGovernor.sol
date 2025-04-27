// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "./CreatorToken.sol";

/// @title CreatorGovernor
/// @notice Simple Governor contract for creator communities to create polls (1 token = 1 vote)
/// @dev Only supports creating polls, no on-chain execution
contract CreatorGovernor is Governor, GovernorSettings, GovernorCountingSimple, GovernorVotes, GovernorVotesQuorumFraction {
    // Creator token
    address public immutable creatorTokenAddress;
    
    // Poll storage
    struct Poll {
        string question;
        string[] options;
        string metadata;  // Additional metadata in JSON or other format
    }
    
    mapping(uint256 => Poll) public polls;
    
    // Events
    event PollCreated(
        uint256 indexed proposalId,
        string question,
        string[] options,
        address creator
    );
    
    /// @notice Constructor sets up the governor with the creator token
    /// @param _name Name of the governor instance
    /// @param _token Token used for voting (must be wrapped as ERC20Votes)
    /// @param _votingDelay Time in blocks between poll creation and voting starts
    /// @param _votingPeriod Time in blocks between voting starts and voting ends
    /// @param _quorumPercentage Percentage of total supply required for quorum
    constructor(
        string memory _name,
        ERC20Votes _token,
        uint256 _votingDelay,
        uint256 _votingPeriod,
        uint256 _quorumPercentage
    )
        Governor(_name)
        GovernorSettings(
            _votingDelay, // voting delay in blocks
            _votingPeriod, // voting period in blocks
            0 // proposal threshold - no tokens needed to create poll
        )
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(_quorumPercentage) // quorum percentage
    {
        require(address(_token) != address(0), "Token cannot be zero address");
        creatorTokenAddress = address(_token);
    }

    /// @notice Creates a new poll
    /// @param question The main poll question
    /// @param options Array of options for the poll
    /// @param metadata Additional metadata about the poll (JSON format recommended)
    /// @return proposalId The ID of the created poll
    function createPoll(
        string calldata question,
        string[] calldata options,
        string calldata metadata
    ) external returns (uint256) {
        require(bytes(question).length > 0, "Question cannot be empty");
        require(options.length >= 2, "Need at least 2 options");
        
        // Create empty calldata for proposal since this is just a poll with no execution
        address[] memory targets = new address[](0);
        uint256[] memory values = new uint256[](0);
        bytes[] memory calldatas = new bytes[](0);
        
        // Use the question as the description
        string memory description = question;
        
        // Create the proposal
        uint256 proposalId = _propose(
            targets,
            values,
            calldatas,
            description
        );
        
        // Store poll data
        polls[proposalId] = Poll({
            question: question,
            options: options,
            metadata: metadata
        });
        
        emit PollCreated(proposalId, question, options, msg.sender);
        
        return proposalId;
    }

    /// @notice Get poll details
    /// @param proposalId ID of the poll
    /// @return question The poll question
    /// @return options The poll options
    /// @return metadata Additional poll metadata
    function getPollDetails(uint256 proposalId) external view returns (
        string memory question,
        string[] memory options,
        string memory metadata
    ) {
        Poll storage poll = polls[proposalId];
        return (poll.question, poll.options, poll.metadata);
    }

    // The following functions are overrides required by Solidity

    function votingDelay() public view override(Governor, GovernorSettings) returns (uint256) {
        return super.votingDelay();
    }

    function votingPeriod() public view override(Governor, GovernorSettings) returns (uint256) {
        return super.votingPeriod();
    }

    function quorum(uint256 blockNumber) public view override(Governor, GovernorVotesQuorumFraction) returns (uint256) {
        return super.quorum(blockNumber);
    }

    function proposalThreshold() public view override(Governor, GovernorSettings) returns (uint256) {
        return super.proposalThreshold();
    }
    
    /// @notice Override execute to make it a no-op since polls don't need execution
    function _execute(
        uint256, // proposalId
        address[] memory, // targets
        uint256[] memory, // values
        bytes[] memory, // calldatas
        bytes32 // descriptionHash
    ) internal override {
        // No execution for polls
    }
}
