
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./ICommonFunctions.sol";
import "./AddressManager.sol";
import "./DataStr.sol";
import "./BusNFT.sol";
import "./SharedStorage.sol"; 

contract Government {
    ICommonFunctions public SharedStorage; // Interface to interact with sharedStorage
    AddressManager public addressManager; // For access control
    BusNFT public busNftContract; // For NFT functionalities

    constructor(address _busNftContractAddress, address _sharedStorageAddress, address _addressManagerAddress) {
      require(_busNftContractAddress != address(0), "BusNFT contract address cannot be zero.");
        require(_sharedStorageAddress != address(0), "sharedStorage address cannot be zero.");
        require(_addressManagerAddress != address(0), "AddressManager address cannot be zero.");

        busNftContract = BusNFT(_busNftContractAddress);
        SharedStorage = ICommonFunctions(_sharedStorageAddress);
        addressManager = AddressManager(_addressManagerAddress);
    }

    event BusRejected(uint256 busId, string note, address updatedBy);
    event BusNoted(uint256 busId, string note, address updatedBy);

    modifier onlyGovernment() {
        require(addressManager.isGovernmentAddressAllowed(msg.sender), "Caller is not an authorized government entity.");
        _;
    }

    event NftTokenIdUpdated(uint256 busId, uint256 nftTokenId);

    function getBusesByCompany(address companyAddress) public view returns (DataStr.BusItem[] memory) {
        return SharedStorage.getBusesByCompany(companyAddress);
    }

    // Function to approve a bus and mint an NFT for it
   function approveBusAndMintNFT(uint256 busId, string memory nftTokenURI) external onlyGovernment returns (uint256) {
        require(SharedStorage.getBusStatus(busId) == DataStr.BusStatus.Forward_To_Goverment, "Bus is not ready to be approved.");

        uint256 newTokenId = busNftContract.mint(busId, nftTokenURI);
        SharedStorage.updateNft(busId, newTokenId);

        SharedStorage.updateBusStatus(busId, DataStr.BusStatus.Approved, "Approved by government", msg.sender);

        return newTokenId;
   }

     function getBusData(uint256 busId) public view returns (DataStr.BusItem memory) {
        return SharedStorage.getBusData(busId);
    }

   function rejectBusWithReason(uint256 busId, string memory reason) external onlyGovernment {
        require(busId > 0, "a message From Govenment Contract:  YOU Are LOOKING FOR a bus that does not exist!");
        DataStr.BusItem memory bus = getBusData(busId);
        require(bus.status == DataStr.BusStatus.Forward_To_Goverment 
                , "Govenment Contract:Bus cannot be Noted in its current state.");
        SharedStorage.updateBusStatus(busId, DataStr.BusStatus.Rejected, reason, msg.sender);
        emit BusRejected(busId, reason, msg.sender);
        emit DataStr.BusRejected(busId, reason, address(this));
   }

   function noteBusWithReason(uint256 busId, string memory note) external onlyGovernment {
        require(busId > 0, "a message From Govenment Contract:  YOU Are LOOKING FOR a bus that does not exist!");
        DataStr.BusItem memory bus = getBusData(busId);
        require(bus.status == DataStr.BusStatus.Forward_To_Goverment 
                , "Govenment Contract:Bus cannot be Noted in its current state.");
        SharedStorage.updateBusStatus(busId, DataStr.BusStatus.Noted, note, msg.sender);
        emit BusNoted(busId, note, msg.sender);
        emit DataStr.BusNoted(busId, note, address(this));
   }
   
    function getBusesOwnedByGovernment() public view onlyGovernment returns (DataStr.BusItem[] memory) {
        return SharedStorage.getBusesOwnedBy(address(this));
    }

   function revokeBusApproval(uint256 busId) public onlyGovernment {
        //later I will add Logic for revoking an approval
    }

    
}