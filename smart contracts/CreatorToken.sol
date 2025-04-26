// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title CreatorToken
/// @notice ERC20 token for a single creator, non-transferable, optionally capped, with role-based minting.
contract CreatorToken is ERC20, ERC20Burnable, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 private _cap;

    /// @notice Emitted when tokens are minted
    event Mint(address indexed to, uint256 amount);

    /// @notice Returns the cap on the token's total supply.
    function cap() public view returns (uint256) {
        return _cap;
    }

    /// @notice Constructor
    /// @param name Token name
    /// @param symbol Token symbol
    /// @param minter Address to be granted MINTER_ROLE
    /// @param cap_ Maximum token supply (0 for uncapped)
    constructor(string memory name, string memory symbol, address minter, uint256 cap_) ERC20(name, symbol) {
        require(minter != address(0), "Minter cannot be zero address");
        _cap = cap_;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, minter);
    }

    /// @notice Mint new tokens (only MINTER_ROLE)
    /// @param to Recipient address
    /// @param amount Amount to mint
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        if (_cap > 0) {
            require(totalSupply() + amount <= _cap, "Cap exceeded");
        }
        _mint(to, amount);
        emit Mint(to, amount);
    }

    /// @notice Change the minter (only admin)
    /// @param newMinter Address to grant MINTER_ROLE
    function setMinter(address newMinter) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(newMinter != address(0), "Minter cannot be zero address");
        _grantRole(MINTER_ROLE, newMinter);
    }

    /// @notice Update the maximum token supply cap
    /// @param newCap New cap value (must be >= totalSupply)
    function setCap(uint256 newCap) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(newCap >= totalSupply(), "New cap must be >= total supply");
        _cap = newCap;
    }

    // Override _update (ERC20 >= 4.8.0) or _beforeTokenTransfer (older OZ)
    function _update(address from, address to, uint256 value) internal override {
        // Allow minting (from == address(0)) and burning (to == address(0))
        if (from != address(0) && to != address(0)) {
            revert("Transfers disabled: token is non-transferable");
        }
        super._update(from, to, value);
    }
}
