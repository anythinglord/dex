// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./IERC20.sol";

interface IPair is IERC20 {
    /**
     * @dev Mints LP tokens to `to` proportional to the tokens sent to the Pair.
     * @return liquidity The amount of LP tokens minted.
     */
    function mint(address to) external returns (uint liquidity);

    /**
     * @dev Burns LP tokens held by this contract and sends the underlying
     *      token amounts to `to`.
     * @return amount0 Amount of token0 returned.
     * @return amount1 Amount of token1 returned.
     */
    function burn(address to) external returns (uint amount0, uint amount1);

    /**
     * @dev Swaps tokens: sends `amount0Out`/`amount1Out` to `to` first (optimistic
     *      transfer), then checks that k did not decrease after any callback.
     * @param data Optional calldata forwarded to `to` if it is a contract (flash swap).
     */
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    /**
     * @dev Reads both reserves and the timestamp of the last update.
     * @return reserve0 Reserve of token0 (uint112 packed).
     * @return reserve1 Reserve of token1 (uint112 packed).
     * @return blockTimestampLast Unix timestamp of the last reserve update.
     */
    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}
