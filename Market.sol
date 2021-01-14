pragma solidity ^0.7.0;
pragma abicoder v2;

// SPDX-License-Identifier: SimPL-2.0

import "./interface/IERC20.sol";
import "./interface/IERC721.sol";
import "./interface/IERC721TokenReceiver.sol";

import "./lib/Util.sol";

import "./Member.sol";

contract Market is Member, IERC721TokenReceiver {
    struct Comm {
        uint256 id;
        address owner;
        address nft;
        uint256 nftId;
        address money;
        uint256 price;
    }
    
    Comm[] public comms;
    uint256 public idCount = 0;
    
    mapping(address => mapping(address => uint256)) public balances;
    uint256 public feeRatio = Util.UDENO * 10 / 100;
    
    function commLength() external view returns(uint256) {
        return comms.length;
    }
    
    function getComms(uint256 startIndex, uint256 endIndex,
        address owner, address nft, address money)
        external view returns(Comm[] memory, uint256[] memory) {
        
        if (endIndex == 0) {
            endIndex = comms.length;
        }
        
        uint256 length = 0;
        
        for (uint256 i = startIndex; i != endIndex; ++i) {
            Comm storage comm = comms[i];
            
            if (owner != address(0) && owner != comm.owner) {
                continue;
            }
            
            if (nft != address(0) && nft != comm.nft) {
                continue;
            }
            
            if (money != address(0) && money != comm.money) {
                continue;
            }
            
            ++length;
        }
        
        Comm[] memory result = new Comm[](length);
        uint256[] memory indexs = new uint256[](length);
        
        uint256 len = 0;
        for (uint256 i = startIndex; len != length; ++i) {
            Comm storage comm = comms[i];
            
            if (owner != address(0) && owner != comm.owner) {
                continue;
            }
            
            if (nft != address(0) && nft != comm.nft) {
                continue;
            }
            
            if (money != address(0) && money != comm.money) {
                continue;
            }
            
            result[len++] = comm;
        }
        
        return (result, indexs);
    }
    
    function onERC721Received(address, address from,
        uint256 nftId, bytes memory data)
        external override returns(bytes4) {
        
        uint256 operate = uint8(data[0]);
        
        if (operate == 1) {
            uint256 money = 0;
            for (uint256 i = 1; i != 33; ++i) {
                money = (money << 8) | uint8(data[i]);
            }
            
            uint256 price = 0;
            for (uint256 i = 33; i != 65; ++i) {
                price = (price << 8) | uint8(data[i]);
            }
            
            _addComm(from, msg.sender, nftId, address(money), price);
        } else {
            return 0;
        }
        
        return Util.ERC721_RECEIVER_RETURN;
    }
    
    function _addComm(address owner, address nft, uint256 nftId,
        address money, uint256 price) internal {
        
        comms.push(Comm({
            id: ++idCount,
            owner: owner,
            nft: nft,
            nftId: nftId,
            money: money,
            price: price
        }));
    }
    
    function removeComm(uint256 index, uint256 id) external {
        Comm storage comm = comms[index];
        require(comm.id == id, "id not match");
        require(comm.owner == msg.sender, "you are not owner");
        
        IERC721(comm.nft).transferFrom(
            address(this), comm.owner, comm.nftId);
        
        comms[index] = comms[comms.length - 1];
        comms.pop();
    }
    
    function buy(uint256 index, uint256 id) external payable {
        Comm storage comm = comms[index];
        require(comm.id == id, "id not match");
        
        address payable cashier = payable(manager.members("cashier"));
        uint256 fee = comm.price * feeRatio / Util.UDENO;
        
        if (comm.money == address(0)) {
            require(msg.value == comm.price, "invalid money amount");
            cashier.transfer(fee);
        } else {
            IERC20 money = IERC20(comm.money);
            require(money.transferFrom(msg.sender, address(this), comm.price),
                "transfer money failed");
            require(money.transferFrom(address(this), cashier, fee),
                "transfer money failed");
        }
        
        balances[comm.owner][comm.money] += comm.price - fee;
        
        IERC721(comm.nft).transferFrom(
            address(this), msg.sender, comm.nftId);
        
        comms[index] = comms[comms.length - 1];
        comms.pop();
    }
    
    function setFeeRatio(uint256 fr) external CheckPermit("Config") {
        feeRatio = fr;
    }
    
    function withdraw(address money) external {
        address payable owner = msg.sender;
        
        uint256 balance = balances[owner][money];
        require(balance > 0, "no balance");
        delete balances[owner][money];
        
        if (money == address(0)) {
            owner.transfer(balance);
        } else {
            require(IERC20(money).transfer(owner, balance),
                "transfer money failed");
        }
    }
}
