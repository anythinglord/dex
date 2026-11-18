// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./IERC20.sol";

/// @notice Stub of WETH9 for future use. The MVP does not support ETH/WETH (spec §16).
interface IWETH9 is IERC20 {
    /// @dev Sends ETH to the contract and mints WETH 1:1.
    function deposit() external payable;

    /// @dev Burns WETH and returns ETH 1:1.
    function withdraw(uint256 wad) external;

    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);
}
