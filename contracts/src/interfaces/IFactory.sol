// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IFactory {
    /**
     * @dev Emitted when a new pair is created.
     * @param token0 The lower token address (sorted).
     * @param token1 The higher token address (sorted).
     * @param pair The address of the newly created Pair contract.
     * @param length Total number of pairs after creation.
     */
    event PairCreated(address indexed token0, address indexed token1, address pair, uint length);

    /**
     * @dev Creates the pair for tokenA/tokenB if it does not exist.
     * @return pair The address of the created Pair (or the existing one).
     */
    function createPair(address tokenA, address tokenB) external returns (address pair);

    /**
     * @dev Returns the pair address between tokenA and tokenB, or address(0) if it does not exist.
     */
    function getPair(address tokenA, address tokenB) external view returns (address pair);

    /**
     * @dev Returns the pair address at position `index` in the listing.
     */
    function allPairs(uint index) external view returns (address pair);

    /**
     * @dev Total number of pairs created in the factory.
     */
    function allPairsLength() external view returns (uint);
}
