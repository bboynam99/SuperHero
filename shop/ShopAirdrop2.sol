pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

import "./ShopRandom.sol";

contract ShopAirdrop2 is ShopRandom {
    function airdrop(address[] memory tos)
        external CheckPermit("Admin") {
        
        uint256 length = tos.length;
        
        for (uint256 i = 0; i != length; ++i) {
            _buy(tos[i], address(0), tokenAmount, 1, 0);
        }
    }
}
