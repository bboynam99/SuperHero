pragma solidity ^0.7.0;
pragma abicoder v2;

// SPDX-License-Identifier: SimPL-2.0

import "../lib/Util.sol";

import "./Shop.sol";

abstract contract ShopLuck is Shop {
    struct Product {
        uint256 rarity;
        uint256 tokenAmount;
        uint256 weight;
    }
    
    Product[] public products;
    
    constructor() {
        products.push(Product({
            rarity: Util.RARITY_BLUE,
            tokenAmount: 10 ** 12 * 20,
            weight: 650000
        }));
        products.push(Product({
            rarity: Util.RARITY_PURPLE,
            tokenAmount: 10 ** 12 * 40,
            weight: 300000
        }));
        products.push(Product({
            rarity: Util.RARITY_ORANGE,
            tokenAmount: 10 ** 12 * 80,
            weight: 49625
        }));
        products.push(Product({
            rarity: Util.RARITY_GOLD,
            tokenAmount: 10 ** 12 * 500,
            weight: 375
        }));
    }
    
    function addProduct(Product memory product)
        external CheckPermit("Config") {
        
        products.push(product);
    }
    
    function removeProduct(uint256 index)
        external CheckPermit("Config") {
        
        products[index] = products[products.length - 1];
        products.pop();
    }
    
    function setProduct(uint256 index, Product memory product)
        external CheckPermit("Config") {
        
        products[index] = product;
    }
    
    function _buyLuck(address to, uint256 quantity, uint256 padding) internal {
        quantityCount += quantity;
        require(quantityCount <= quantityMax, "quantity exceed");
        
        Package(manager.members("package")).mint(
            to, 0, quantity, padding);
    }
    
    function onOpenPackage(address, uint256 packageId, bytes32 bh)
        external override returns(uint256[] memory) {
        
        require(msg.sender == manager.members("package"), "package only");
        
        uint256 productLength = products.length;
        uint256[] memory weights = new uint256[](productLength);
        uint256 weightTotal = 0;
        
        for (uint256 i = 0; i != productLength; ++i) {
            uint256 weight = products[i].weight;
            weights[i] = weight;
            weightTotal += weight;
        }
        
        uint256 quantity = uint16(packageId >> 144);
        
        uint256[] memory cardIdPres = new uint256[](quantity);
        
        uint256 tokenAmount = 0;
        
        for (uint256 i = 0; i != quantity; ++i) {
            uint256 cardType = calcCardType(abi.encode(bh, packageId, i));
            
            uint256 random = Util.randomWeight(
                abi.encode(bh, packageId, i, 1), weights, weightTotal);
            Product storage product = products[random];
            
            cardIdPres[i] = (cardType << 224) | (product.rarity << 192)
                | (product.tokenAmount << 128);
                
            tokenAmount += product.tokenAmount;
        }
        
        IERC20(manager.members("token")).transfer(
            manager.members("card"), tokenAmount);
        
        return cardIdPres;
    }
        
    function getRarityWeights(uint256)
        external view override returns(uint256[] memory) {
        
        uint256 length = products.length;
        uint256[] memory weights = new uint256[](6);
        
        for (uint256 i = 0; i != length; ++i) {
            Product storage product = products[i];
            weights[product.rarity] += product.weight;
        }
        
        return weights;
    }
}
