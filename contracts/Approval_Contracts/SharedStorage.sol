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
    //uint256 private nextBusId = 1; // Assuming bus ID starts from 1
    using Counters for Counters.Counter;
    Counters.Counter private _nextBusId;
    
    // Events
    // Correcting the event to match your sharedStorage usage
    
    //event BusStatusUpdated(uint256 indexed id, DataStr.BusStatus newStatus, string note, address updatedBy);
    //event BusOwnershipUpdated(uint256 indexed id, address newOwner);
    
    event NftTokenIdUpdated(uint256 busId, uint256 nftTokenId);

    // Modifier to check if bus exists
    modifier busExists(uint256 busId) {
        require(buses[busId].id >= 0, "THE YOU Are LOOKING FOR does not exist!!!!");
        _;
    }

    modifier onlyGovernment() {
    require(addressManager.isGovernmentAddressAllowed(msg.sender), "Government is not authorized as government.");
    _;
    }

      modifier onlyCompany() {
    require(addressManager.isCompanyAddressAllowed(msg.sender), "Comapny is not authorized as government.");
    _;
    }
    constructor() {
        // Initialize _nextBusId to start with 1
        _nextBusId.increment();
    }

    // Function to add a new bus
    function addBus(
        uint256 model, 
        string calldata vim_number, 
        uint256 company_ID, 
        string calldata plate_number, 
        address creator
        ) external override {
            
        buses[_nextBusId.current()] = DataStr.BusItem({
            id: _nextBusId.current(),
            model: model,
            vim_number: vim_number,
            company_ID: company_ID,
            plate_number: plate_number,
            // expireYear: expireYear, // Removed this line
            status: DataStr.BusStatus.New_Bus,
            rejectNote: "",
            rejectBy: address(0),
            owner: creator,
            creator: creator,
            nftTokenId: 0
        });
    
        
        emit DataStr.BusCreated(
            _nextBusId.current(),
            model,
            vim_number,
            company_ID,
            plate_number,
            // expireYear, // Removed this parameter
            DataStr.BusStatus.New_Bus,
            "",
            address(0),
            creator,
            creator,
            0
        );
        _nextBusId.increment();
    
    }

     // Function to get the current status of a bus by its ID
    function getBusStatus(uint256 busId) external view override returns (DataStr.BusStatus) {
        require(buses[busId].id >= 0, "Bus does not exist with the ID you write it!!!");
        return buses[busId].status;
    }

    // Function to update bus status
    function updateBusStatus(uint256 id, DataStr.BusStatus newStatus, string calldata note, address updatedBy) external override busExists(id) {
        buses[id].status = newStatus;
        
        // Check if the newStatus is either Rejected or Noted
        if(newStatus == DataStr.BusStatus.Rejected || newStatus == DataStr.BusStatus.Noted) {
            buses[id].rejectNote = note;
            buses[id].rejectBy = updatedBy;
        }
        emit DataStr.BusStatusUpdated(id, newStatus, note, updatedBy);
    }


    // Function to update bus ownership
    function updateOwnership(uint256 id, address newOwner) external override busExists(id) {
        require(newOwner != address(0), "SharedStorage: New owner cannot be zero address.");
        buses[id].owner = newOwner;

        emit DataStr.OwnershipUpdated(id, newOwner);
    }

    // Function to get a bus by ID
    function getBusData(uint256 id) external view override busExists(id) returns (DataStr.BusItem memory) {
       return buses[id];
    }

    function updateNft(uint256 busId, uint256 nftTokenId) external onlyGovernment busExists(busId) {
        buses[busId].nftTokenId = nftTokenId;
        emit NftTokenIdUpdated(busId, nftTokenId); // Emit an event for the update
    }

    function getBusesByCompanyID(uint256 companyID) external view returns (DataStr.BusItem[] memory) {
        uint256 totalBusCount = _nextBusId.current() - 1; // Assuming _nextBusId is incremented after adding a bus
        uint256 matchingBusCount = 0;

        // First pass: count the matching buses to allocate memory for the array
        for (uint256 i = 1; i <= totalBusCount; i++) {
            if (buses[i].company_ID == companyID) {
                matchingBusCount++;
            }
        }

        // Allocate array with matching size
        DataStr.BusItem[] memory matchingBuses = new DataStr.BusItem[](matchingBusCount);
        uint256 arrayIndex = 0;

        // Second pass: populate the array with matching buses
        for (uint256 i = 1; i <= totalBusCount; i++) {
            if (buses[i].company_ID == companyID) {
                matchingBuses[arrayIndex] = buses[i];
                arrayIndex++;
            }
        }

        return matchingBuses;
    }

}
