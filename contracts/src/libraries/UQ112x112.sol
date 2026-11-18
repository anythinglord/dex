// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title UQ112x112 fixed-point number library
/// @notice Used for oracle price accumulation in Pair contract
/// @dev Represents numbers as uint224 with 112 bits integer + 112 bits fractional
library UQ112x112 {
    uint224 constant Q112 = 2**112;

    /// @notice Encodes a uint112 as a UQ112x112 (shifts left by 112 bits)
    /// @param value The uint112 value to encode
    /// @return The UQ112x112 representation
    function encode(uint112 value) internal pure returns (uint224) {
        return uint224(value) * Q112;
    }

    /// @notice Multiplies a UQ112x112 by a uint256, returning uint256 (truncates decimals)
    /// @param self The UQ112x112 value
    /// @param y The uint256 multiplier
    /// @return The result as uint256 (integer part only)
    function uq112x112(uint256 self, uint256 y) internal pure returns (uint256) {
        return (self * y) >> 112;
    }

    /// @notice Decodes a UQ112x112 to uint144 (truncates decimals)
    /// @param self The UQ112x112 value to decode
    /// @return The uint144 result (integer part)
    function decode(uint224 self) internal pure returns (uint144) {
        // forge-lint: disable-next-line(unsafe-typecast) // self/Q112 ≤ 2^112-1 < uint144.max
        return uint144(self / Q112);
    }
}
