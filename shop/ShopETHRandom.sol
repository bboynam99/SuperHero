pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

import "./ShopRandom.sol";

contract ShopETHRandom is ShopRandom {
    function buy(uint256 quantity) external payable {
        require(msg.value == price * quantity, "invalid msg.value");
        address payable cashier = payable(manager.members("cashier"));
        cashier.transfer(msg.value);
        
        _buyRandom(quantity, 0);
    }
}
