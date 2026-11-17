// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/libraries/Math.sol";
import "../src/libraries/SafeCast.sol";
import "../src/libraries/UQ112x112.sol";

// Wrapper to test internal library functions with expectRevert
contract SafeCastWrapper {
    function toUint112(uint256 value) external pure returns (uint112) {
        return SafeCast.toUint112(value);
    }
}

contract LibrariesTest is Test {
    using Math for uint256;
    using UQ112x112 for uint112;
    using UQ112x112 for uint224;

    SafeCastWrapper safeCastWrapper;

    function setUp() public {
        safeCastWrapper = new SafeCastWrapper();
    }

    // ============ Math.sqrt ============

    function testSqrt_PerfectSquares() public pure {
        assertEq(Math.sqrt(0), 0);
        assertEq(Math.sqrt(1), 1);
        assertEq(Math.sqrt(4), 2);
        assertEq(Math.sqrt(9), 3);
        assertEq(Math.sqrt(16), 4);
        assertEq(Math.sqrt(25), 5);
        assertEq(Math.sqrt(100), 10);
    }

    function testSqrt_NonPerfectSquares() public pure {
        assertEq(Math.sqrt(2), 1);  // floors
        assertEq(Math.sqrt(3), 1);
        assertEq(Math.sqrt(5), 2);
        assertEq(Math.sqrt(8), 2);
        assertEq(Math.sqrt(10), 3);
    }

    function testSqrt_LargeValues() public pure {
        uint256 large = 1e18; // 10^18
        assertEq(Math.sqrt(large), 1e9); // 10^9
    }

    function testFuzz_Sqrt(uint256 y) public pure {
        // Bound to avoid overflow in intermediate calculations
        vm.assume(y < type(uint128).max);
        
        uint256 result = Math.sqrt(y);
        // result^2 <= y < (result+1)^2
        assertLe(result * result, y);
        
        // Check that (result+1)^2 > y or overflows
        if (result < type(uint256).max / 2) {
            uint256 next = result + 1;
            assertTrue(next * next > y || next * next < result * result);
        }
    }

    // ============ Math.min ============

    function testMin_ReturnsSmaller() public pure {
        assertEq(Math.min(5, 10), 5);
        assertEq(Math.min(10, 5), 5);
        assertEq(Math.min(7, 7), 7);
        assertEq(Math.min(0, 100), 0);
    }

    // ============ SafeCast.toUint112 ============

    function testSafeCast_WithinBounds() public pure {
        uint256 value = type(uint112).max;
        assertEq(SafeCast.toUint112(value), type(uint112).max);
    }

    function testSafeCast_Overflow() public {
        uint256 value = uint256(type(uint112).max) + 1;
        vm.expectRevert("SafeCast: overflow");
        safeCastWrapper.toUint112(value);
    }

    // ============ UQ112x112 ============

    function testUQ112x112_EncodeDecode() public pure {
        uint112 value = 100;
        uint224 encoded = value.encode();
        uint144 decoded = UQ112x112.decode(encoded);
        assertEq(decoded, value);
    }

    function testUQ112x112_RoundTrip() public pure {
        uint112 value = 12345;
        uint224 encoded = value.encode();
        // encode: value * 2^112
        assertEq(encoded, uint224(value) * 2**112);
        // decode: encoded / 2^112
        assertEq(UQ112x112.decode(encoded), value);
    }

    function testUQ112x112_Mul() public pure {
        uint112 price = 2; // 2.0 in fixed-point
        uint224 encoded = price.encode();
        uint256 quantity = 50;
        uint256 result = encoded.uq112x112(quantity);
        assertEq(result, 100); // 2 * 50 = 100
    }
}
