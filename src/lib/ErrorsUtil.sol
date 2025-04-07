// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title BitMath
/// @dev This library provides functionality for computing bit properties of an unsigned integer
library ErrorsUtil {
    error AlreadyInitialized();
    error FlashLoanNotPaid();
    error InsufficientInputAmount();
    error InvalidPriceLimit();
    error InvalidTickRange();
    error NotEnoughLiquidity();
    error ZeroLiquidity();

    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint256 amount0,
        uint256 amount1
    );

    event Flash(address indexed recipient, uint256 amount0, uint256 amount1);

    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );

    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );
}