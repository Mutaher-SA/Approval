// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "./ICommonFunctions.sol";
import "./AddressManager.sol";
import "./DataStr.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract sharedStorage is ICommonFunctions { 
 
    DataStr.BusItem public busItem;
    AddressManager public addressManager;
    // State variables
    mapping(uint256 => DataStr.BusItem) private buses;
    uint256 private nextBusId = 1; // Assuming bus ID starts from 1
    using Counters for Counters.Counter;
    Counters.Counter private _nextBusId;
    
    // Events
    event BusAdded(uint256 indexed id, uint256 model, string vim_number, uint256 company_number, string plate_number, uint256 expireYear, DataStr.BusStatus status, string rejectNote, address owner, address creator);
    event BusStatusUpdated(uint256 indexed id, DataStr.BusStatus newStatus, string note, address updatedBy);
    event BusOwnershipUpdated(uint256 indexed id, address newOwner);

    // Modifier to check if bus exists
    modifier busExists(uint256 busId) {
        require(buses[busId].id > 0, "SharedStorage: Bus does not exist.");
        _;
    }

    modifier onlyGovernment() {
    require(addressManager.isGovernmentAddressAllowed(msg.sender), "Caller is not authorized as government.");
    _;
}


    // Function to add a new bus
    function addBus(uint256 model, string calldata vim_number, uint256 company_number, string calldata plate_number, address creator) external override {
        uint256 expireYear = model + 10; // Example logic for expireYear

        buses[nextBusId] = DataStr.BusItem({
            id: _nextBusId.current(),
            model: model,
            vim_number: vim_number,
            company_number: company_number,
            plate_number: plate_number,
            expireYear: expireYear,
            status: DataStr.BusStatus.New_Bus,
            rejectNote: "",
            rejectBy: address(0),
            owner: creator,
            creator: creator,
            nftTokenId: 0 // Assuming NFT token ID will be assigned later
        });
        _nextBusId.increment();
        emit BusAdded(nextBusId, model, vim_number, company_number, plate_number, expireYear, DataStr.BusStatus.Waiting, "", creator, creator);
        
    }

     // Function to get the current status of a bus by its ID
    function getBusStatus(uint256 busId) external view override returns (DataStr.BusStatus) {
        require(buses[busId].id > 0, "Bus does not exist.");
        return buses[busId].status;
    }

    // Function to update bus status
    function updateBusStatus(uint256 id, DataStr.BusStatus newStatus, string calldata note, address updatedBy) external override busExists(id) {
        buses[id].status = newStatus;
        buses[id].rejectNote = note;
        buses[id].rejectBy = updatedBy;

        emit BusStatusUpdated(id, newStatus, note, updatedBy);
    }

    // Function to update bus ownership
    function updateOwnership(uint256 id, address newOwner) external override busExists(id) {
        require(newOwner != address(0), "SharedStorage: New owner cannot be zero address.");
        buses[id].owner = newOwner;

        emit BusOwnershipUpdated(id, newOwner);
    }

    // Function to get a bus by ID
    function getBusData(uint256 id) external view override busExists(id) returns (DataStr.BusItem memory) {
        return buses[id];
    }

    function updateNft(uint256 busId, uint256 nftTokenId) external onlyGovernment {
        require(buses[busId].id > 0, "Bus does not exist.");
        buses[busId].nftTokenId = nftTokenId;
        emit DataStr.NftTokenIdUpdated(busId, nftTokenId); // Optional: Emit an event for the update
}


    // Additional functions as per the ICommonFunction interface
    // Implement other functions from the interface as needed...
  
}