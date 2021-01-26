pragma solidity ^0.7.0;
pragma abicoder v2;

// SPDX-License-Identifier: SimPL-2.0

import "../interface/IERC20.sol";

import "./ShopLuck.sol";

contract ShopTokenLuck is ShopLuck {
    uint256 public price = 10 ** 12 * 30;
    
    function setPrice(uint256 _price)
        external CheckPermit("Config") {
        
        price = _price;
    }
    
    function buy(uint256 quantity) external {
        IERC20(manager.members("token")).transferFrom(
            msg.sender, address(this), price * quantity);
        
        _buyLuck(msg.sender, quantity, 0);
    }
}
