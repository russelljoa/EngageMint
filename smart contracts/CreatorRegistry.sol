// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/// @title CreatorRegistry
/// @notice Source of truth for all creators, tokens, and authorized distributor addresses
/// @dev Provides onlyCreator modifier for access control across the suite
contract CreatorRegistry is AccessControl, Pausable {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant DISTRIBUTOR_ROLE = keccak256("DISTRIBUTOR_ROLE");

    // Creator status enum
    enum CreatorStatus { Inactive, Active, Suspended }

    // Creator info struct
    struct CreatorInfo {
        address creatorAddress;      // Creator's wallet address
        address tokenAddress;        // Address of the creator's token contract
        CreatorStatus status;        // Current status of the creator
        string metadataURI;          // URI for off-chain metadata (profile, links, etc.)
        uint256 registrationTime;    // When the creator was registered
        bool governorEnabled;        // Whether the creator has enabled governance
        address governorAddress;     // Address of the creator's governor contract (if enabled)
    }

    // Mappings
    mapping(address => CreatorInfo) public creators;                 // Creator address => info
    mapping(address => address) public tokenToCreator;               // Token address => creator address
    mapping(address => bool) public isCreator;                       // Quick check if address is a creator
    mapping(address => mapping(address => bool)) public isAuthorized; // Creator => distributor => authorized

    // Events
    event CreatorRegistered(address indexed creator, address indexed tokenAddress, string metadataURI);
    event CreatorUpdated(address indexed creator, string metadataURI);
    event CreatorStatusChanged(address indexed creator, CreatorStatus status);
    event TokenRegistered(address indexed creator, address indexed tokenAddress);
    event DistributorAuthorized(address indexed creator, address indexed distributor, bool authorized);
    event GovernorEnabled(address indexed creator, address indexed governorAddress);
    event GovernorDisabled(address indexed creator);

    /// @notice Constructor sets up admin role
    /// @param admin Address to be granted the admin role
    constructor(address admin) {
        require(admin != address(0), "Admin cannot be zero address");
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
    }

    /// @notice Modifier that only allows creators to call a function
    modifier onlyCreator() {
        require(isCreator[msg.sender], "Caller is not a registered creator");
        require(creators[msg.sender].status == CreatorStatus.Active, "Creator is not active");
        _;
    }

    /// @notice Modifier that allows only the specific creator or an admin
    /// @param creator The creator address to check against
    modifier onlyCreatorOrAdmin(address creator) {
        require(
            msg.sender == creator || hasRole(ADMIN_ROLE, msg.sender),
            "Caller is neither the creator nor an admin"
        );
        _;
    }

    /// @notice Register a new creator
    /// @param creator Creator address
    /// @param tokenAddress Address of the creator's token contract
    /// @param metadataURI URI for creator metadata
    function registerCreator(
        address creator, 
        address tokenAddress, 
        string calldata metadataURI
    ) external onlyRole(ADMIN_ROLE) whenNotPaused {
        require(creator != address(0), "Creator cannot be zero address");
        require(tokenAddress != address(0), "Token address cannot be zero address");
        require(!isCreator[creator], "Creator already registered");
        require(tokenToCreator[tokenAddress] == address(0), "Token already registered to another creator");
        require(bytes(metadataURI).length > 0, "Metadata URI cannot be empty");

        // Create and store the creator info
        CreatorInfo memory newCreator = CreatorInfo({
            creatorAddress: creator,
            tokenAddress: tokenAddress,
            status: CreatorStatus.Active,
            metadataURI: metadataURI,
            registrationTime: block.timestamp,
            governorEnabled: false,
            governorAddress: address(0)
        });

        creators[creator] = newCreator;
        tokenToCreator[tokenAddress] = creator;
        isCreator[creator] = true;

        emit CreatorRegistered(creator, tokenAddress, metadataURI);
        emit TokenRegistered(creator, tokenAddress);
    }

    /// @notice Update a creator's metadata
    /// @param creator Creator address
    /// @param metadataURI New URI for creator metadata
    function updateCreatorMetadata(
        address creator, 
        string calldata metadataURI
    ) external onlyCreatorOrAdmin(creator) whenNotPaused {
        require(isCreator[creator], "Creator not registered");
        require(bytes(metadataURI).length > 0, "Metadata URI cannot be empty");

        creators[creator].metadataURI = metadataURI;
        
        emit CreatorUpdated(creator, metadataURI);
    }

    /// @notice Change a creator's status
    /// @param creator Creator address
    /// @param status New creator status
    function changeCreatorStatus(
        address creator, 
        CreatorStatus status
    ) external onlyRole(ADMIN_ROLE) {
        require(isCreator[creator], "Creator not registered");
        
        creators[creator].status = status;
        
        emit CreatorStatusChanged(creator, status);
    }

    /// @notice Authorize a distributor for a creator
    /// @param distributor Distributor address
    /// @param authorized Whether the distributor is authorized
    function authorizeDistributor(
        address distributor, 
        bool authorized
    ) external onlyCreator whenNotPaused {
        require(distributor != address(0), "Distributor cannot be zero address");
        
        isAuthorized[msg.sender][distributor] = authorized;
        
        emit DistributorAuthorized(msg.sender, distributor, authorized);
    }

    /// @notice Admin function to authorize a distributor for a creator
    /// @param creator Creator address
    /// @param distributor Distributor address
    /// @param authorized Whether the distributor is authorized
    function adminAuthorizeDistributor(
        address creator, 
        address distributor, 
        bool authorized
    ) external onlyRole(ADMIN_ROLE) whenNotPaused {
        require(isCreator[creator], "Creator not registered");
        require(distributor != address(0), "Distributor cannot be zero address");
        
        isAuthorized[creator][distributor] = authorized;
        
        emit DistributorAuthorized(creator, distributor, authorized);
    }

    /// @notice Set or update a creator's governor contract
    /// @param governorAddress Address of the governor contract
    function setGovernor(address governorAddress) external onlyCreator whenNotPaused {
        require(governorAddress != address(0), "Governor cannot be zero address");
        
        creators[msg.sender].governorEnabled = true;
        creators[msg.sender].governorAddress = governorAddress;
        
        emit GovernorEnabled(msg.sender, governorAddress);
    }

    /// @notice Disable a creator's governor
    function disableGovernor() external onlyCreator whenNotPaused {
        require(creators[msg.sender].governorEnabled, "Governor already disabled");
        
        creators[msg.sender].governorEnabled = false;
        
        emit GovernorDisabled(msg.sender);
    }

    /// @notice Check if a distributor is authorized for a creator
    /// @param creator Creator address
    /// @param distributor Distributor address
    /// @return Whether the distributor is authorized
    function isDistributorAuthorized(address creator, address distributor) external view returns (bool) {
        return isAuthorized[creator][distributor] || hasRole(DISTRIBUTOR_ROLE, distributor);
    }

    /// @notice Get a creator's token address
    /// @param creator Creator address
    /// @return The creator's token address
    function getCreatorToken(address creator) external view returns (address) {
        return creators[creator].tokenAddress;
    }

    /// @notice Get a token's creator
    /// @param tokenAddress Token address
    /// @return The creator address associated with the token
    function getTokenCreator(address tokenAddress) external view returns (address) {
        return tokenToCreator[tokenAddress];
    }

    /// @notice Get a creator's governor address
    /// @param creator Creator address
    /// @return governorAddress The creator's governor address
    /// @return enabled Whether the governor is enabled
    function getCreatorGovernor(address creator) external view returns (address governorAddress, bool enabled) {
        return (creators[creator].governorAddress, creators[creator].governorEnabled);
    }

    /// @notice Grant the distributor role to an address
    /// @param distributor Address to grant the distributor role
    function addGlobalDistributor(address distributor) external onlyRole(ADMIN_ROLE) {
        require(distributor != address(0), "Distributor cannot be zero address");
        _grantRole(DISTRIBUTOR_ROLE, distributor);
    }

    /// @notice Revoke the distributor role from an address
    /// @param distributor Address to revoke the distributor role from
    function removeGlobalDistributor(address distributor) external onlyRole(ADMIN_ROLE) {
        _revokeRole(DISTRIBUTOR_ROLE, distributor);
    }

    /// @notice Get the status of a creator
    /// @param creator Creator address
    /// @return status The creator's status
    function getCreatorStatus(address creator) external view returns (CreatorStatus status) {
        status = creators[creator].status;
    }

    /// @notice Pause the registry
    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    /// @notice Unpause the registry
    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }
}
