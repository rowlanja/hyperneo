// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "./ERC20Mintable.sol";
import "../src/NeoswapPool.sol";


contract UniswapV3PoolTest {

    UniswapV3Pool pool;
    Token token0;
    Token token1;

    bool shouldTransferInCallback = true;

    struct TestCaseParams {
        uint256 wethBalance;
        uint256 usdcBalance;
        int24 currentTick;
        int24 lowerTick;
        int24 upperTick;
        uint128 liquidity;
        uint160 currentSqrtP;
        bool shouldTransferInCallback;
        bool mintLiqudity;
    }

    function beforeAll () public {
        token0 = new Token("Ether", "ETH");
        token1 = new Token("USDC", "USDC");
    }

    function testMintSuccess () public {
        console.log("Running pool test 1");
        TestCaseParams memory params = TestCaseParams({
            wethBalance: 1 ether,
            usdcBalance: 5000 ether,
            currentTick: 85176,
            lowerTick: 84222,
            upperTick: 86129,
            liquidity: 1517882343751509868544,
            currentSqrtP: 5602277097478614198912276234240,
            shouldTransferInCallback: true,
            mintLiqudity: true
        });

        (uint256 poolBalance0, uint256 poolBalance1) = setupTestCase(params);

        uint256 expectedAmount0 = 0.998976618347425280 ether;
        uint256 expectedAmount1 = 5000 ether;
        console.log(poolBalance0);
        console.log(expectedAmount0);

        console.log(poolBalance1);
        console.log(expectedAmount1);

        require(poolBalance0 == expectedAmount0);
        require(poolBalance1 == expectedAmount1);
        console.log(poolBalance0);

        require(token0.balanceOf(address(pool)) == expectedAmount0);
        require(token1.balanceOf(address(pool)) == expectedAmount1);

        // bytes32 positionKey = keccak256(
        //     abi.encodePacked(address(this), params.lowerTick, params.upperTick)
        // );

        // uint128 posLiquidity = pool.positions(positionKey);
        // Assert.equal(posLiquidity, params.liquidity, "Liquidty is incorrect");

        // (uint160 sqrtPriceX96, int24 tick) = pool.slot0();
        // Assert.equal(
        //     sqrtPriceX96,
        //     5604469350942327889444743441197,
        //     "invalid current sqrtP"
        // );
        // console.log(sqrtPriceX96);

        // Assert.equal(tick, 85176, "invalid current tick");
        // Assert.equal(
        //     pool.liquidity(),
        //     1517882343751509868544,
        //     "invalid current liquidity"
        // );

        console.log("Ran all tests");
    }

    function testSwapBuyEth() public {
        TestCaseParams memory params = TestCaseParams({
            wethBalance: 1 ether,
            usdcBalance: 5000 ether,
            currentTick: 85176,
            lowerTick: 84222,
            upperTick: 86129,
            liquidity: 1517882343751509868544,
            currentSqrtP: 5602277097478614198912276234240,
            shouldTransferInCallback: true,
            mintLiqudity: true
        });
        (uint256 poolBalance0, uint256 poolBalance1) = setupTestCase(params);

        uint256 swapAmount = 42 ether; // 42 USDC
        token1.mint(address(this), swapAmount);
        token1.approve(address(this), swapAmount);

        (int256 amount0Delta, int256 amount1Delta) = pool.swap(address(this));

        int256 userBalance0Before = int256(token0.balanceOf(address(this)));

        Assert.equal(amount0Delta, -0.008396714242162444 ether, "invalid ETH out");
        Assert.equal(amount1Delta, 42 ether, "invalid USDC in");

        // Assert.equal(
        //     token0.balanceOf(address(this)),
        //     uint256(userBalance0Before - amount0Delta),
        //     "invalid user ETH balance"
        // );
        // Assert.equal(
        //     token1.balanceOf(address(this)),
        //     0,
        //     "invalid user USDC balance"
        // );

        // Assert.equal(
        //     token0.balanceOf(address(pool)),
        //     uint256(int256(poolBalance0) + amount0Delta),
        //     "invalid pool ETH balance"
        // );
        // Assert.equal(
        //     token1.balanceOf(address(pool)),
        //     uint256(int256(poolBalance1) + amount1Delta),
        //     "invalid pool USDC balance"
        // );

        // (uint160 sqrtPriceX96, int24 tick) = pool.slot0();
        // Assert.equal(
        //     sqrtPriceX96,
        //     5604469350942327889444743441197,
        //     "invalid current sqrtP"
        // );
        // Assert.equal(tick, 85184, "invalid current tick");
        // Assert.equal(
        //     pool.liquidity(),
        //     1517882343751509868544,
        //     "invalid current liquidity"
        // );

    }

    function uniswapV3SwapCallback(int256 amount0, int256 amount1) public {
        if (amount0 > 0) {
            token0.transfer(msg.sender, uint256(amount0));
        }

        if (amount1 > 0) {
            token1.transfer(msg.sender, uint256(amount1));
        }
    }

    function setupTestCase(TestCaseParams memory params) internal returns (uint256 poolBalance0, uint256 poolBalance1) {
        token0.mint(address(this), params.wethBalance);
        token1.mint(address(this), params.usdcBalance);

        pool = new UniswapV3Pool(
            address(token0),
            address(token1),
            params.currentSqrtP,
            params.currentTick
        );

        if (params.mintLiqudity) {
            console.log("approving");
            token0.approve(address(this), params.wethBalance);
            token1.approve(address(this), params.usdcBalance);
            console.log("callback");
            UniswapV3Pool.CallbackData memory extra = UniswapV3Pool
                .CallbackData({
                    token0: address(token0),
                    token1: address(token1),
                    payer: address(this)
                });
            console.log("minting");
            (poolBalance0, poolBalance1) = pool.mint(
                address(this),
                params.lowerTick,
                params.upperTick,
                params.liquidity,
                abi.encode(extra)
            );
            console.log("finished");
        }

        shouldTransferInCallback = params.shouldTransferInCallback;
    }

    function uniswapV3MintCallback(
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) public {
        if (shouldTransferInCallback) {
            UniswapV3Pool.CallbackData memory extra = abi.decode(
                data,
                (UniswapV3Pool.CallbackData)
            );

            IERC20(extra.token0).transferFrom(extra.payer, msg.sender, amount0);
            IERC20(extra.token1).transferFrom(extra.payer, msg.sender, amount1);
        }
    }

}