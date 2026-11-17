// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title SafeCast utilities
/// @notice Safe downcasting with revert on overflow
library SafeCast {
    /// @notice Converts uint256 to uint112, reverting if value exceeds uint112 max
    /// @param value The uint256 value to cast
    /// @return result The uint112 result
    function toUint112(uint256 value) internal pure returns (uint112 result) {
        require(value <= type(uint112).max, "SafeCast: overflow");
        result = uint112(value);
    }
}
