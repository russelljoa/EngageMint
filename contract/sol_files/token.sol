// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title $ishowspeed Token (simple port from Ink!)
contract IshowspeedToken {
    /* -------------------------------------------------------------------------- */
    /*                             Immutable metadata                             */
    /* -------------------------------------------------------------------------- */
    string  public constant name     = "$ishowspeed";
    string  public constant symbol   = "SPEED";
    uint8   public constant decimals = 18;

    /* -------------------------------------------------------------------------- */
    /*                                 State vars                                 */
    /* -------------------------------------------------------------------------- */
    uint256 public totalSupply;
    address public immutable admin;
    mapping(address => uint256) public balanceOf;

    /* -------------------------------------------------------------------------- */
    /*                                    Events                                  */
    /* -------------------------------------------------------------------------- */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* -------------------------------------------------------------------------- */
    /*                                  Errors                                    */
    /* -------------------------------------------------------------------------- */
    error NotAdmin();
    error InsufficientBalance();

    /* -------------------------------------------------------------------------- */
    /*                                Constructor                                 */
    /* -------------------------------------------------------------------------- */
    constructor() {
        admin = msg.sender;
    }

    /* -------------------------------------------------------------------------- */
    /*                               Admin minting                                */
    /* -------------------------------------------------------------------------- */
    function mint(address to, uint256 value) external {
        if (msg.sender != admin) revert NotAdmin();

        totalSupply += value;
        balanceOf[to] += value;
        emit Transfer(address(0), to, value);
    }

    /* -------------------------------------------------------------------------- */
    /*                                Transfers                                   */
    /* -------------------------------------------------------------------------- */
    function transfer(address to, uint256 value) external returns (bool) {
        uint256 fromBal = balanceOf[msg.sender];
        if (fromBal < value) revert InsufficientBalance();

        unchecked {
            balanceOf[msg.sender] = fromBal - value;
        }
        balanceOf[to] += value;

        emit Transfer(msg.sender, to, value);
        return true;
    }
}