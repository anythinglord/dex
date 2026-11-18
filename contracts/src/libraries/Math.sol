// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Math utilities for the AMM
/// @notice Minimal math helpers used by Pair and LP token logic
library Math {
    /// @notice Returns the smaller of two uint256 values
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /// @notice Integer square root using Newton's method (bisection)
    /// @dev Rounds down. Works for y up to type(uint128).max squared without overflow.
    /// @param y The value to take the square root of
    /// @return z The largest integer z such that z * z <= y
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y <= 1) return y;

        // For y >= 2, sqrt(y) <= y/2 + 1
        z = y / 2 + 1;
        uint256 x;
        
        while (true) {
            x = z;
            z = (y / x + x) / 2;
            if (z >= x) break;
        }
        
        return x;
    }
}
