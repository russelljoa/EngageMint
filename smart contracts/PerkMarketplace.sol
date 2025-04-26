// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./CreatorToken.sol";

/// @title PerkMarketplace
/// @notice Simple token burning mechanism for off-chain marketplace
contract PerkMarketplace is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;
    
    // Essential mapping
    mapping(address => address) public creatorToToken;  // creator => token contract
    
    // Events
    event TokensBurned(address indexed creator, address indexed fan, uint256 amount);
    event CreatorTokenRegistered(address indexed creator, address indexed tokenContract);

    constructor() Ownable(msg.sender) {}

    /// @notice Register a creator token contract
    /// @param creator Creator address
    /// @param tokenContract Address of the creator's token contract
    function registerCreatorToken(address creator, address tokenContract) external onlyOwner {
        require(creator != address(0), "Creator cannot be zero address");
        require(tokenContract != address(0), "Token contract cannot be zero address");
        
        creatorToToken[creator] = tokenContract;
        emit CreatorTokenRegistered(creator, tokenContract);
    }

    /// @notice Burn tokens for a specific creator
    /// @param creator The creator whose tokens to burn
    /// @param amount Amount of tokens to burn
    function burnTokens(address creator, uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be greater than zero");
        
        // Get creator token
        address tokenAddress = creatorToToken[creator];
        require(tokenAddress != address(0), "Creator token not found");
        
        // Burn tokens
        CreatorToken token = CreatorToken(tokenAddress);
        require(token.balanceOf(msg.sender) >= amount, "Insufficient token balance");
        token.burnFrom(msg.sender, amount);
        
        emit TokensBurned(creator, msg.sender, amount);
    }
}
