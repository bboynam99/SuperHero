pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

import "./interface/IERC20.sol";

import "./ShopMortgage.sol";

contract ShopERC20Mortgage is ShopMortgage {
    IERC20 public money;
    
    constructor(address _money, uint256 _startTime,
        uint256 _duration, uint256 _reward)
        ShopMortgage(_startTime, _duration, _reward) {
        
        money = IERC20(_money);
    }
    
    function mortgage(int256 amount) external {
        bool success;
        
        if (amount > 0) {
            success = money.transferFrom(msg.sender, address(this), uint256(amount));
        } else {
            success = money.transfer(msg.sender, uint256(-amount));
        }
        
        require(success, "transfer money failed");
        
        _mortgage(msg.sender, amount);
    }
}
