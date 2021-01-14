pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

import "./interface/IERC20.sol";

import "./ShopRandom.sol";

contract ShopERC20Random is ShopRandom {
    IERC20 public money;
    
    constructor(address _money) {
        money = IERC20(_money);
    }
    
    function buy(uint256 quantity) external {
        bool success = money.transferFrom(msg.sender,
            manager.members("cashier"), price * quantity);
        require(success, "transfer money failed");
        
        _buyRandom(quantity, 0);
    }
}
