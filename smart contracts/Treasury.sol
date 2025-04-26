// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title Treasury
/// @notice Holds platform fees, reserves, and creator token allocations for EngageMint
/// @dev Withdrawals gated by multi-sig or timelock
contract Treasury is AccessControl, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant WITHDRAWER_ROLE = keccak256("WITHDRAWER_ROLE");
    bytes32 public constant PLATFORM_ROLE = keccak256("PLATFORM_ROLE");
    
    // Configuration
    uint256 public timelock;           // Time delay for withdrawals in seconds
    uint256 public minSignatures;      // Minimum signatures required for multi-sig withdrawals
    
    // Withdrawal request structure
    struct WithdrawalRequest {
        address token;          // Address of token to withdraw (zero address for ETH)
        address recipient;      // Address of recipient
        uint256 amount;         // Amount to withdraw
        uint256 unlockTime;     // Timestamp when withdrawal can be executed
        uint256 signatureCount; // Number of signatures received
        bool executed;          // Whether the withdrawal has been executed
        mapping(address => bool) signatures; // Signatures from withdrawers
    }
    
    // Withdrawal request tracking
    uint256 public requestCount;
    mapping(uint256 => WithdrawalRequest) public withdrawalRequests;
    
    // Whitelisted recipient addresses (for added security)
    mapping(address => bool) public whitelistedRecipients;
    
    // Emergency recovery admin for worst-case scenario
    address public emergencyAdmin;
    bool public emergencyAdminActive;
    
    // Events
    event WithdrawalRequested(uint256 indexed requestId, address indexed token, address indexed recipient, uint256 amount, uint256 unlockTime);
    event WithdrawalSigned(uint256 indexed requestId, address indexed signer);
    event WithdrawalExecuted(uint256 indexed requestId, address indexed token, address indexed recipient, uint256 amount);
    event WithdrawalCancelled(uint256 indexed requestId);
    event TimelockUpdated(uint256 newTimelock);
    event MinSignaturesUpdated(uint256 newMinSignatures);
    event RecipientWhitelisted(address indexed recipient, bool status);
    event EmergencyAdminUpdated(address indexed newEmergencyAdmin);
    event EmergencyAdminActivated(bool active);
    event TokensReceived(address indexed token, address indexed from, uint256 amount);
    event NativeTokenReceived(address indexed from, uint256 amount);
    
    /// @notice Constructor sets up roles and configuration
    /// @param _admin Address that will be granted the admin role
    /// @param _withdrawers Array of addresses that will be granted the withdrawer role
    /// @param _platform Address that will be granted the platform role
    /// @param _timelock Time delay for withdrawals in seconds
    /// @param _minSignatures Minimum signatures required for multi-sig withdrawals
    constructor(
        address _admin,
        address[] memory _withdrawers,
        address _platform,
        uint256 _timelock,
        uint256 _minSignatures
    ) {
        require(_admin != address(0), "Admin cannot be zero address");
        require(_platform != address(0), "Platform cannot be zero address");
        require(_withdrawers.length > 0, "Must have at least one withdrawer");
        require(_minSignatures > 0, "Min signatures must be positive");
        require(_minSignatures <= _withdrawers.length, "Min signatures exceeds withdrawer count");
        
        // Grant admin role
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(ADMIN_ROLE, _admin);
        
        // Grant withdrawer roles
        for (uint256 i = 0; i < _withdrawers.length; i++) {
            require(_withdrawers[i] != address(0), "Withdrawer cannot be zero address");
            _grantRole(WITHDRAWER_ROLE, _withdrawers[i]);
        }
        
        // Grant platform role
        _grantRole(PLATFORM_ROLE, _platform);
        
        // Set configuration
        timelock = _timelock;
        minSignatures = _minSignatures;
        
        // Set emergency admin (initially same as admin)
        emergencyAdmin = _admin;
        emergencyAdminActive = false;
        
        // Whitelist admin as recipient
        whitelistedRecipients[_admin] = true;
    }
    
    /// @notice Allows the contract to receive ETH
    receive() external payable {
        emit NativeTokenReceived(msg.sender, msg.value);
    }
    
    /// @notice Initiate a withdrawal request
    /// @param token Address of token to withdraw (zero address for ETH)
    /// @param recipient Address of recipient
    /// @param amount Amount to withdraw
    /// @return requestId The ID of the withdrawal request
    function requestWithdrawal(
        address token,
        address recipient,
        uint256 amount
    ) external onlyRole(WITHDRAWER_ROLE) whenNotPaused nonReentrant returns (uint256) {
        require(recipient != address(0), "Recipient cannot be zero address");
        require(amount > 0, "Amount must be greater than zero");
        require(whitelistedRecipients[recipient], "Recipient not whitelisted");
        
        // Check balance
        if (token == address(0)) {
            require(address(this).balance >= amount, "Insufficient ETH balance");
        } else {
            require(IERC20(token).balanceOf(address(this)) >= amount, "Insufficient token balance");
        }
        
        // Create request ID
        uint256 requestId = requestCount++;
        
        // Create withdrawal request
        WithdrawalRequest storage request = withdrawalRequests[requestId];
        request.token = token;
        request.recipient = recipient;
        request.amount = amount;
        request.unlockTime = block.timestamp + timelock;
        request.signatureCount = 1; // Initiator counts as first signature
        request.executed = false;
        request.signatures[msg.sender] = true;
        
        emit WithdrawalRequested(requestId, token, recipient, amount, request.unlockTime);
        emit WithdrawalSigned(requestId, msg.sender);
        
        return requestId;
    }
    
    /// @notice Sign a withdrawal request
    /// @param requestId ID of the withdrawal request
    function signWithdrawal(uint256 requestId) external onlyRole(WITHDRAWER_ROLE) whenNotPaused nonReentrant {
        WithdrawalRequest storage request = withdrawalRequests[requestId];
        
        require(!request.executed, "Withdrawal already executed");
        require(request.recipient != address(0), "Invalid withdrawal request");
        require(!request.signatures[msg.sender], "Already signed");
        
        request.signatures[msg.sender] = true;
        request.signatureCount++;
        
        emit WithdrawalSigned(requestId, msg.sender);
    }
    
    /// @notice Execute a withdrawal request after timelock expires
    /// @param requestId ID of the withdrawal request
    function executeWithdrawal(uint256 requestId) external whenNotPaused nonReentrant {
        WithdrawalRequest storage request = withdrawalRequests[requestId];
        
        require(!request.executed, "Withdrawal already executed");
        require(request.recipient != address(0), "Invalid withdrawal request");
        require(block.timestamp >= request.unlockTime, "Timelock not expired");
        require(request.signatureCount >= minSignatures, "Insufficient signatures");
        
        // Mark as executed before transfer to prevent reentrancy
        request.executed = true;
        
        // Perform transfer
        if (request.token == address(0)) {
            // Transfer ETH
            (bool success, ) = request.recipient.call{value: request.amount}("");
            require(success, "ETH transfer failed");
        } else {
            // Transfer ERC20
            IERC20(request.token).safeTransfer(request.recipient, request.amount);
        }
        
        emit WithdrawalExecuted(requestId, request.token, request.recipient, request.amount);
    }
    
    /// @notice Cancel a withdrawal request
    /// @param requestId ID of the withdrawal request
    function cancelWithdrawal(uint256 requestId) external onlyRole(ADMIN_ROLE) {
        WithdrawalRequest storage request = withdrawalRequests[requestId];
        
        require(!request.executed, "Withdrawal already executed");
        require(request.recipient != address(0), "Invalid withdrawal request");
        
        // Clear withdrawal by setting recipient to zero address
        request.recipient = address(0);
        
        emit WithdrawalCancelled(requestId);
    }
    
    /// @notice Emergency withdrawal by the emergency admin
    /// @param token Address of token to withdraw (zero address for ETH)
    /// @param recipient Address of recipient
    /// @param amount Amount to withdraw
    function emergencyWithdraw(
        address token,
        address recipient,
        uint256 amount
    ) external nonReentrant {
        require(msg.sender == emergencyAdmin, "Not emergency admin");
        require(emergencyAdminActive, "Emergency admin not active");
        require(recipient != address(0), "Recipient cannot be zero address");
        require(amount > 0, "Amount must be greater than zero");
        
        if (token == address(0)) {
            require(address(this).balance >= amount, "Insufficient ETH balance");
            (bool success, ) = recipient.call{value: amount}("");
            require(success, "ETH transfer failed");
        } else {
            require(IERC20(token).balanceOf(address(this)) >= amount, "Insufficient token balance");
            IERC20(token).safeTransfer(recipient, amount);
        }
        
        emit WithdrawalExecuted(type(uint256).max, token, recipient, amount);
    }
    
    /// @notice Update the timelock duration
    /// @param _timelock New timelock duration in seconds
    function setTimelock(uint256 _timelock) external onlyRole(ADMIN_ROLE) {
        timelock = _timelock;
        emit TimelockUpdated(_timelock);
    }
    
    /// @notice Update the minimum required signatures
    /// @param _minSignatures New minimum signatures required
    function setMinSignatures(uint256 _minSignatures) external onlyRole(ADMIN_ROLE) {
        require(_minSignatures > 0, "Min signatures must be positive");
        uint256 withdrawerCount = 0;
        bytes32 role = WITHDRAWER_ROLE;
        for (uint256 i = 0; i < getRoleMemberCount(role); i++) {
            withdrawerCount++;
        }
        require(_minSignatures <= withdrawerCount, "Min signatures exceeds withdrawer count");
        
        minSignatures = _minSignatures;
        emit MinSignaturesUpdated(_minSignatures);
    }
    
    /// @notice Whitelist or blacklist a recipient
    /// @param recipient Recipient address
    /// @param status Whitelist status
    function setRecipientWhitelist(address recipient, bool status) external onlyRole(ADMIN_ROLE) {
        require(recipient != address(0), "Recipient cannot be zero address");
        whitelistedRecipients[recipient] = status;
        emit RecipientWhitelisted(recipient, status);
    }
    
    /// @notice Update the emergency admin
    /// @param _emergencyAdmin New emergency admin address
    function setEmergencyAdmin(address _emergencyAdmin) external {
        require(msg.sender == emergencyAdmin || hasRole(ADMIN_ROLE, msg.sender), "Not authorized");
        require(_emergencyAdmin != address(0), "Emergency admin cannot be zero address");
        
        emergencyAdmin = _emergencyAdmin;
        emit EmergencyAdminUpdated(_emergencyAdmin);
    }
    
    /// @notice Activate or deactivate the emergency admin
    /// @param active Whether the emergency admin should be active
    function setEmergencyAdminActive(bool active) external onlyRole(ADMIN_ROLE) {
        emergencyAdminActive = active;
        emit EmergencyAdminActivated(active);
    }
    
    /// @notice Add a withdrawer
    /// @param withdrawer Address to grant withdrawer role
    function addWithdrawer(address withdrawer) external onlyRole(ADMIN_ROLE) {
        require(withdrawer != address(0), "Withdrawer cannot be zero address");
        _grantRole(WITHDRAWER_ROLE, withdrawer);
    }
    
    /// @notice Remove a withdrawer
    /// @param withdrawer Address to revoke withdrawer role
    function removeWithdrawer(address withdrawer) external onlyRole(ADMIN_ROLE) {
        _revokeRole(WITHDRAWER_ROLE, withdrawer);
        
        // Ensure minSignatures is still valid
        uint256 withdrawerCount = 0;
        bytes32 role = WITHDRAWER_ROLE;
        for (uint256 i = 0; i < getRoleMemberCount(role); i++) {
            withdrawerCount++;
        }
        
        if (minSignatures > withdrawerCount && withdrawerCount > 0) {
            minSignatures = withdrawerCount;
            emit MinSignaturesUpdated(minSignatures);
        }
    }
    
    /// @notice Deposit ERC20 tokens directly to the treasury
    /// @param token Address of the token
    /// @param amount Amount to deposit
    function depositToken(address token, uint256 amount) external nonReentrant {
        require(token != address(0), "Use native token function");
        require(amount > 0, "Amount must be greater than zero");
        
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        emit TokensReceived(token, msg.sender, amount);
    }
    
    /// @notice Pause the contract
    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }
    
    /// @notice Unpause the contract
    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }
    
    /// @notice Get the signature status of a user for a withdrawal
    /// @param requestId ID of the withdrawal request
    /// @param signer Address to check
    /// @return Whether the user has signed the withdrawal
    function hasSignedWithdrawal(uint256 requestId, address signer) external view returns (bool) {
        return withdrawalRequests[requestId].signatures[signer];
    }
    
    /// @notice Get all signatures for a withdrawal request
    /// @param requestId ID of the withdrawal request
    /// @return count Number of signatures
    function getWithdrawalSignatureCount(uint256 requestId) external view returns (uint256 count) {
        return withdrawalRequests[requestId].signatureCount;
    }
    
    /// @notice Get the current balance of a token
    /// @param token Address of the token (zero address for ETH)
    /// @return Balance of the token
    function getBalance(address token) external view returns (uint256) {
        if (token == address(0)) {
            return address(this).balance;
        } else {
            return IERC20(token).balanceOf(address(this));
        }
    }
}
