// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./CreatorToken.sol";

/// @title CreatorTokenFactory
/// @notice Factory contract for deploying and managing CreatorToken contracts
/// @dev Tracks creator to token mappings and handles optional onboarding fees
contract CreatorTokenFactory is Ownable {
    // Mapping from creator address to their token address
    mapping(address => address) public creatorToToken;
    
    // Fee configuration
    bool public paidOnboardingEnabled;
    uint256 public setupFee;
    address public feeCollector;
    
    // Events
    event TokenCreated(address indexed creator, address indexed token);
    event PaidOnboardingStatusChanged(bool enabled);
    event SetupFeeChanged(uint256 newFee);
    event FeeCollectorChanged(address newFeeCollector);
    
    /// @notice Constructor
    /// @param initialOwner Address that will own this factory contract
    constructor(address initialOwner) Ownable(initialOwner) {
        paidOnboardingEnabled = false;
        setupFee = 0;
        feeCollector = initialOwner;
    }
    
    /// @notice Creates a new CreatorToken for a creator
    /// @param name Token name
    /// @param symbol Token symbol
    /// @param minter The address to grant minting rights (typically the creator or a platform contract)
    /// @param cap Maximum token supply (0 for uncapped)
    /// @return The address of the newly created token
    function createToken(
        string memory name,
        string memory symbol,
        address minter,
        uint256 cap
    ) external payable returns (address) {
        // Check if creator already has a token
        require(creatorToToken[msg.sender] == address(0), "Creator already has a token");
        
        // Handle setup fee if paid onboarding is enabled
        if (paidOnboardingEnabled) {
            require(msg.value >= setupFee, "Insufficient fee");
            
            // Forward the fee to the fee collector
            (bool sent, ) = feeCollector.call{value: msg.value}("");
            require(sent, "Failed to send fee");
        } else if (msg.value > 0) {
            // If fee was sent but not required, refund it
            (bool sent, ) = msg.sender.call{value: msg.value}("");
            require(sent, "Failed to refund");
        }
        
        // Create new token with factory as the initial admin
        CreatorToken token = new CreatorToken(name, symbol, minter, cap);
        
        // Store creator to token mapping
        creatorToToken[msg.sender] = address(token);
        
        // Transfer admin role from factory to the creator
        token.grantRole(token.DEFAULT_ADMIN_ROLE(), msg.sender);
        token.revokeRole(token.DEFAULT_ADMIN_ROLE(), address(this));
        
        // Emit event
        emit TokenCreated(msg.sender, address(token));
        
        return address(token);
    }
    
    /// @notice Enable or disable paid onboarding
    /// @param enabled Whether paid onboarding should be enabled
    function setPaidOnboardingEnabled(bool enabled) external onlyOwner {
        paidOnboardingEnabled = enabled;
        emit PaidOnboardingStatusChanged(enabled);
    }
    
    /// @notice Set the setup fee
    /// @param fee New setup fee amount
    function setSetupFee(uint256 fee) external onlyOwner {
        setupFee = fee;
        emit SetupFeeChanged(fee);
    }
    
    /// @notice Set the fee collector address
    /// @param collector New fee collector address
    function setFeeCollector(address collector) external onlyOwner {
        require(collector != address(0), "Fee collector cannot be zero address");
        feeCollector = collector;
        emit FeeCollectorChanged(collector);
    }
    
    /// @notice Get the token address for a specific creator
    /// @param creator Creator address
    /// @return Token address or zero address if none exists
    function getCreatorToken(address creator) external view returns (address) {
        return creatorToToken[creator];
    }
}
