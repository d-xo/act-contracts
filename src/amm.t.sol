// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.3;
pragma experimental SMTChecker;

import {ERC20} from "./erc20.sol";
import {AMM} from "./amm.sol";

contract Tests {
    function k_is_preserved(uint joinAmt, uint swapAmt) external {
        ERC20 token0 = new ERC20(type(uint).max);
        ERC20 token1 = new ERC20(type(uint).max);

        AMM amm = new AMM(
            address(token0),
            address(token1)
        );

        token0.approve(address(amm), type(uint).max);
        token1.approve(address(amm), type(uint).max);

        amm.join(joinAmt, joinAmt);
        amm.swap(
            address(token0),
            address(token1),
            swapAmt
        );
    }
}
