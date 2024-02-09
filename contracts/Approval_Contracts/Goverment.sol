
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

    modifier onlyGovernment() {
        require(addressManager.isGovernmentAddressAllowed(msg.sender), "Caller is not an authorized government entity.");
        _;
    }

    event NftTokenIdUpdated(uint256 busId, uint256 nftTokenId);

    function getBusesByCompany(address companyAddress) external view returns (DataStr.BusItem[] memory) {
        return SharedStorage.getBusesByCompany(companyAddress);
    }

    // Function to approve a bus and mint an NFT for it
   function approveBusAndMintNFT(uint256 busId, string memory nftTokenURI) public onlyGovernment returns (uint256) {
        require(SharedStorage.getBusStatus(busId) == DataStr.BusStatus.Forward_To_Goverment, "Bus is not ready to be approved.");

        uint256 newTokenId = busNftContract.mint(busId, nftTokenURI);
        SharedStorage.updateNft(busId, newTokenId);

        SharedStorage.updateBusStatus(busId, DataStr.BusStatus.Approved, "Approved by government", msg.sender);

        return newTokenId;
   }

   function rejectBusWithReason(uint256 busId, string memory reason) public onlyGovernment {
        // Ensure the bus is in a state that allows for rejection
        require(SharedStorage.getBusStatus(busId) != DataStr.BusStatus.Approved, "Bus already approved.");
        SharedStorage.updateBusStatus(busId, DataStr.BusStatus.Rejected, reason, msg.sender);
        emit DataStr.BusRejected(busId, reason, msg.sender);
   }

   function noteBusWithReason(uint256 busId, string memory note) public onlyGovernment {
        require(SharedStorage.getBusStatus(busId) != DataStr.BusStatus.Approved, "Bus already approved.");
        SharedStorage.updateBusStatus(busId, DataStr.BusStatus.Noted, note, msg.sender);
        emit DataStr.BusNoted(busId, note, msg.sender);
   }
   
   function getBusesOwnedByGovernment() external view returns (uint256[] memory) {
        uint256 totalBuses = SharedStorage.getTotalNumberOfBuses(); 
        uint256[] memory tempArray = new uint256[](totalBuses);
        uint256 count = 0;

        for (uint256 i = 1; i <= totalBuses; i++) {
            DataStr.BusItem memory bus = SharedStorage.getBusData(i);
            if (bus.owner == address(this)) { // Use address(this) to refer to the coordinator's address
                tempArray[count] = bus.id;
                count++;
            }
        }

        // Create a fitted array based on the actual count
        uint256[] memory busesOwnedByGov = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            busesOwnedByGov[i] = tempArray[i];
        }

        return busesOwnedByGov;
    }

   function revokeBusApproval(uint256 busId) public onlyGovernment {
        //later I will add Logic for revoking an approval
    }

    
}