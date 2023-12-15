// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract property {
      address ContractOwner;
      
      struct propertydetails 
      {
        uint _prodID;
        address CurrentOwner;
        string _PropertyAddr;
        address[] PrevOwner;
      }

      mapping(uint => propertydetails) public details;
      
      constructor()  
      {
        ContractOwner = msg.sender;
      }

      function uploadproperty(uint _prodID, address _CurrentOwner, string memory _PropertyAddr) public returns(bool) 
      {
        address[] memory array;
        details[_prodID] = propertydetails(_prodID, _CurrentOwner, _PropertyAddr, array);
        return true;
      }

      function transfer(uint _prodID, address _NewOwner) public returns (bool) 
      {
        require(details[_prodID].CurrentOwner == msg.sender, "YOU ARE NOT THE OWNER OF THIS PROPERTY");
        require(details[_prodID].CurrentOwner != _NewOwner);
        details[_prodID].PrevOwner.push(details[_prodID].CurrentOwner);
        details[_prodID].CurrentOwner = _NewOwner;
        return true;
      }
      
      function propertydetail(uint _prodID) public view returns(string memory PROPERTY_ADDRESS, address CURRENT_OWNER, address[] memory PREVIOUS_OWNER){
        return(details[_prodID]._PropertyAddr, details[_prodID].CurrentOwner, details[_prodID].PrevOwner);
      }

    
}

pragma solidity ^0.8.0;

contract AssetTransfer {
    struct Asset {
        uint id;
        uint value;
        address payable owner;
        // other asset details
    }

    mapping(uint => Asset) public assets;

    event Transfer(uint indexed id, address indexed from, address indexed to, uint value);

    function transferAsset(uint _assetId, address payable _to, uint _priceCondition) public payable {
        require(assets[_assetId].owner == msg.sender, "You do not own this asset");

        Asset storage asset = assets[_assetId];
        require(asset.value >= _priceCondition, "Asset value does not meet the price condition");

        require(msg.value >= asset.value, "Insufficient payment");

        asset.owner.transfer(asset.value); // Send payment to the current owner
        asset.owner = _to;

        emit Transfer(_assetId, msg.sender, _to, asset.value);
    }
}
