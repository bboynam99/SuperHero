pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

import "./ShopMortgage.sol";

contract ShopETHMortgage is ShopMortgage {
    constructor(uint256 _startTime, uint256 _duration, uint256 _reward)
       ShopMortgage(_startTime, _duration, _reward) {
    }
    
    function mortgage(int256 amount) external payable {
        address payable sender = payable(msg.sender);
        
        if (amount > 0) {
            require(msg.value == uint256(amount), "invalid msg.value");
        } else {
            sender.transfer(uint256(-amount));
        }
        
        _mortgage(sender, amount);
    }
}
