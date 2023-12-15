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

contract AssetMarket {
    struct Asset {
        uint id;
        uint price;
        address payable owner;
        bool isAvailable;
    }

    mapping(uint => Asset) public assets;

    event AssetPurchased(uint indexed assetId, address indexed buyer, uint price);

    function addAsset(uint _assetId, uint _price) external {
        require(!assets[_assetId].isAvailable, "Asset with this ID already exists");

        assets[_assetId] = Asset(_assetId, _price, payable(msg.sender), true);
    }

    function buyAsset(uint _assetId) external payable {
        Asset storage asset = assets[_assetId];

        require(asset.isAvailable, "Asset is not available");
        require(msg.value >= asset.price, "Insufficient funds");

        asset.owner.transfer(asset.price); // Transfer payment to the asset owner
        asset.owner = payable(msg.sender); // Update the asset owner
        asset.isAvailable = false; // Mark the asset as no longer available

        emit AssetPurchased(_assetId, msg.sender, asset.price);
    }
}

