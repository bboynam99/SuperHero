pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

import "./Shop.sol";

contract ShopAladdin is Shop {
    function buy(uint256 rarity, uint256 tokenAmount, uint256 quantity)
        external CheckPermit("Config") {
        
        _buy(msg.sender, msg.sender, tokenAmount, quantity, rarity);
    }
    
    function onOpenPackage(address, uint256 packageId, bytes32 bh)
        external view override returns(uint256[] memory) {
        
        uint256 tokenAmount = uint64(packageId >> 160);
        uint256 quantity = uint16(packageId >> 144);
        uint256 rarity = uint16(packageId >> 104);
        
        uint256[] memory cardIdPres = new uint256[](quantity);
        
        for (uint256 i = 0; i != quantity; ++i) {
            uint256 cardType = calcCardType(abi.encode(bh, packageId, i));
            cardIdPres[i] = (cardType << 224) | (rarity << 192) | (tokenAmount << 128);
        }
        
        return cardIdPres;
    }
    
    function getRarityWeights(uint256 packageId)
        external pure override returns(uint256[] memory) {
        
        uint256[] memory weights = new uint256[](6);
        
        uint256 rarity = uint16(packageId >> 104);
        weights[rarity] = 1;
        
        return weights;
    }
}
