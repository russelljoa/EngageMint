// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./CreatorRegistry.sol";
import "./CreatorToken.sol";

/// @title RewardDistributor
/// @notice Simple contract to mint creator tokens to fans from off-chain
/// @dev Simplified for off-chain script integration
contract RewardDistributor is AccessControl, Pausable, ReentrancyGuard {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    // Reference to the CreatorRegistry
    CreatorRegistry public immutable creatorRegistry;
    
    // Events
    event TokenMinted(
        address indexed creator,
        address indexed recipient,
        uint256 amount
    );
    
    /// @notice Constructor
    /// @param _creatorRegistry Address of the CreatorRegistry contract
    /// @param admin Address to be granted admin role
    /// @param minter Initial authorized minter address
    constructor(
        address _creatorRegistry,
        address admin,
        address minter
    ) {
        require(_creatorRegistry != address(0), "Registry cannot be zero address");
        require(admin != address(0), "Admin cannot be zero address");
        require(minter != address(0), "Minter cannot be zero address");
        
        creatorRegistry = CreatorRegistry(_creatorRegistry);
        
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, minter);
    }
    
    /// @notice Mints tokens to a recipient based on off-chain calculation
    /// @param creator Address of the creator whose tokens to mint
    /// @param recipient Address to receive the minted tokens
    /// @param amount Amount of tokens to mint
    function mintTokens(
        address creator,
        address recipient,
        uint256 amount
    ) external nonReentrant whenNotPaused onlyRole(MINTER_ROLE) {
        // Verify creator is valid
        require(creatorRegistry.isCreator(creator), "Not a registered creator");
        require(creatorRegistry.getCreatorStatus(creator) == CreatorRegistry.CreatorStatus.Active, "Creator not active");
        
        // Get token address from registry
        address tokenAddress = creatorRegistry.getCreatorToken(creator);
        require(tokenAddress != address(0), "Creator has no token");
        
        // Mint tokens to the recipient
        CreatorToken token = CreatorToken(tokenAddress);
        token.mint(recipient, amount);
        
        // Emit event
        emit TokenMinted(creator, recipient, amount);
    }
    
    /// @notice Add a new authorized minter
    /// @param minter Address to grant minter role
    function addMinter(address minter) external onlyRole(ADMIN_ROLE) {
        require(minter != address(0), "Minter cannot be zero address");
        _grantRole(MINTER_ROLE, minter);
    }
    
    /// @notice Remove an authorized minter
    /// @param minter Address to revoke minter role
    function removeMinter(address minter) external onlyRole(ADMIN_ROLE) {
        _revokeRole(MINTER_ROLE, minter);
    }
    
    /// @notice Pause the distributor
    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }
    
    /// @notice Unpause the distributor
    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }
}
