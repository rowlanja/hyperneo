// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

library FixedPoint96 {
    uint8 internal constant RESOLUTION = 96;
    uint256 internal constant Q96 = 2**96;
}