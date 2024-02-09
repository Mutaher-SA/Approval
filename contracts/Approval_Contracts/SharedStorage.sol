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
        require(buses[busId].id > 0, "THE YOU Are LOOKING FOR does not exist!!!!");
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
    
    // Assuming the existence of DataStr.BusItem, _nextBusId, and other necessary parts

    function addBus(
        uint256 model, 
        string calldata vim_number,
        uint256 company_ID, 
        string calldata plate_number,
        address creator,
        address companyContractAddress
    ) external override {
        buses[_nextBusId.current()] = DataStr.BusItem({
            id: _nextBusId.current(),
            model: model,
            vim_number: vim_number,
            company_ID: company_ID,
            plate_number: plate_number,
            status: DataStr.BusStatus.New_Bus,
            rejectNote: "",
            rejectBy: address(0),
            owner: companyContractAddress, // Use the provided address as the owner
            creator: creator,
            nftTokenId: 0
        });

        emit DataStr.BusCreated(
            _nextBusId.current(),
            model,
            vim_number,
            company_ID,
            plate_number,
            DataStr.BusStatus.New_Bus,
            "",
            address(0),
            companyContractAddress, // Reflecting the change here too
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

    function getBusesByCompany(address companyAddress) external view override returns (DataStr.BusItem[] memory) {
        uint256 totalBuses = _nextBusId.current();
        uint256 count = 0;

        // First pass: count the buses
        for (uint256 i = 1; i < totalBuses; i++) {
            if (buses[i].creator == companyAddress) {
                count++;
            }
    }

        // Second pass: populate the array
        DataStr.BusItem[] memory companyBuses = new DataStr.BusItem[](count);
        uint256 index = 0;
        for (uint256 i = 1; i < totalBuses; i++) {
            if (buses[i].creator == companyAddress) {
                companyBuses[index] = buses[i];
                index++;
            }
        }

        return companyBuses;
    }

    function getBuses_Company_Status(address companyAddress, DataStr.BusStatus status) external view override returns (DataStr.BusItem[] memory) {
        uint256 totalBuses = _nextBusId.current();
        uint256 count = 0;

        // First pass: count the buses that match the company address and status
        for (uint256 i = 1; i < totalBuses; i++) {
            if (buses[i].creator == companyAddress && buses[i].status == status) {
                count++;
            }
        }

        // Allocate memory for the array based on the count
        DataStr.BusItem[] memory filteredBuses = new DataStr.BusItem[](count);
        uint256 index = 0;

        // Second pass: populate the array with buses that match the criteria
        for (uint256 i = 1; i < totalBuses; i++) {
            if (buses[i].creator == companyAddress && buses[i].status == status) {
                filteredBuses[index] = buses[i];
                index++;
            }
        }

        return filteredBuses;
    }

    function getTotalNumberOfBuses() public view override returns (uint256) {
        require(_nextBusId.current()>0,"a message from Storage contract: Counter in not started yet!");
        return _nextBusId.current() - 1;
    }

}
