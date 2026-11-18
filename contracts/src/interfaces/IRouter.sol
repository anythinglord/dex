// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IRouter {
    /**
     * @dev Adds liquidity to a pair. Computes the optimal amounts and transfers
     *      both tokens to the Pair. If the pair has no liquidity, uses the desired amounts.
     * @return amountA Actual amount of tokenA transferred.
     * @return amountB Actual amount of tokenB transferred.
     * @return liquidity LP tokens minted for `to`.
     */
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    /**
     * @dev Removes liquidity: burns LP tokens and returns both tokens to `to`.
     * @return amountA Amount of tokenA returned.
     * @return amountB Amount of tokenB returned.
     */
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    /**
     * @dev Swaps exactly `amountIn` of the first token in the path for the last one.
     *      Walks the path hop by hop via the Pairs.
     * @param path Token addresses, starting and ending with the token being sold.
     * @return amounts Amount at each hop: amounts[0] = amountIn, amounts[last] = output.
     */
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}
