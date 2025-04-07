// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.14;

import "./MathUtil.sol";

library SwapMath {
    function computeSwapStep(
        uint160 sqrtPriceCurrentX96,
        uint160 sqrtPriceTargetX96,
        uint128 liquidity,
        uint256 amountRemaining,
        uint24 fee
    )
        internal
        pure
        returns (
            uint160 sqrtPriceNextX96,
            uint256 amountIn,
            uint256 amountOut,
            uint256 feeAmount
        )
    {
        bool zeroForOne = sqrtPriceCurrentX96 >= sqrtPriceTargetX96;
        uint256 amountRemainingLessFee = Common.mulDiv(
            amountRemaining,
            1e6 - fee,
            1e6
        );

        amountIn = zeroForOne
            ? MathUtil.calcAmount0Delta(
                sqrtPriceCurrentX96,
                sqrtPriceTargetX96,
                liquidity,
                true
            )
            : MathUtil.calcAmount1Delta(
                sqrtPriceCurrentX96,
                sqrtPriceTargetX96,
                liquidity,
                true
            );

        if (amountRemainingLessFee >= amountIn)
            sqrtPriceNextX96 = sqrtPriceTargetX96;
        else
            sqrtPriceNextX96 = MathUtil.getNextSqrtPriceFromInput(
                sqrtPriceCurrentX96,
                liquidity,
                amountRemainingLessFee,
                zeroForOne
            );

        bool max = sqrtPriceNextX96 == sqrtPriceTargetX96;

        if (zeroForOne) {
            amountIn = max
                ? amountIn
                : MathUtil.calcAmount0Delta(
                    sqrtPriceCurrentX96,
                    sqrtPriceNextX96,
                    liquidity,
                    true
                );
            amountOut = MathUtil.calcAmount1Delta(
                sqrtPriceCurrentX96,
                sqrtPriceNextX96,
                liquidity,
                false
            );
        } else {
            amountIn = max
                ? amountIn
                : MathUtil.calcAmount1Delta(
                    sqrtPriceCurrentX96,
                    sqrtPriceNextX96,
                    liquidity,
                    true
                );
            amountOut = MathUtil.calcAmount0Delta(
                sqrtPriceCurrentX96,
                sqrtPriceNextX96,
                liquidity,
                false
            );
        }

        if (!max) {
            feeAmount = amountRemaining - amountIn;
        } else {
            feeAmount = MathUtil.mulDivRoundingUp(amountIn, fee, 1e6 - fee);
        }
    }
}
