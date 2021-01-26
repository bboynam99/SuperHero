pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

import "../lib/Util.sol";

import "./Shop.sol";

contract ShopAirdrop is Shop {
    uint256 public tokenAmount;
    
    function setTokenAmount(uint256 amount)
        external CheckPermit("Config") {
        
        tokenAmount = amount;
    }
    
    function airdrop(address[] memory tos)
        external CheckPermit("Admin") {
        
        uint256 length = tos.length;
        
        for (uint256 i = 0; i != length; ++i) {
            _buy(tos[i], address(0), tokenAmount, 1, 0);
        }
    }
    
    function onOpenPackage(address, uint256 packageId, bytes32 bh)
        external view override returns(uint256[] memory) {
        
        uint256 amount = uint64(packageId >> 160);
        uint256 quantity = uint16(packageId >> 144);
        
        uint256[] memory cardIdPres = new uint256[](quantity);
        
        for (uint256 i = 0; i != quantity; ++i) {
            uint256 cardType = calcCardType(abi.encode(bh, packageId, i));
            uint256 rarity = Util.RARITY_ORANGE;
            
            cardIdPres[i] = (cardType << 224) | (rarity << 192) | (amount << 128);
        }
        
        return cardIdPres;
    }
        
    function getRarityWeights(uint256)
        external pure override returns(uint256[] memory) {
        
        uint256[] memory weights = new uint256[](6);
        weights[Util.RARITY_ORANGE] = 1;
        
        return weights;
    }
}
