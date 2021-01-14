pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

import "./MortgageBase.sol";
import "./ShopExchange.sol";

abstract contract ShopMortgage is ShopExchange, MortgageBase {
    constructor(uint256 _startTime, uint256 _duration, uint256 _reward)
        MortgageBase(_startTime, _duration, _reward) {
    }
    
    function buy(uint256 quantity) external {
        uint256 reward = _withdraw();
        
        if (block.timestamp > startTime + totalDuration &&
            reward <= rarityAmounts[0]) {
            
            _buy(msg.sender, address(0), reward, 1, 0);
        } else {
            _buyExchange(address(0), reward / quantity, quantity, 0);
        }
    }
}
