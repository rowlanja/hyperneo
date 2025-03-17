pragma solidity ^0.8.14;

import "../src/UniswapV3Pool.sol";
import "../src/interfaces/IERC20.sol";

contract NeoswapManager {
    function mint(
        address poolAddress_,
        int24 lowerTick,
        int24 upperTick,
        uint128 liquidity,
        bytes calldata data
    ) public {
        NeoswapPool(poolAddress_).mint(
            msg.sender,
            lowerTick,
            upperTick,
            liquidity,
            data
        );
    }

    function swap(
        address poolAddress_, bytes calldata data
    ) public {
        NeoswapPool(poolAddress_).swap(msg.sender, data);
    }
}