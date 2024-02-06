// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "./ICommonFunctions.sol";
import "./AddressManager.sol";
import "./DataStr.sol"; // For the struct and enum definitions

contract Company {
    // Address of the sharedStorage contract to interact with the data layer
    ICommonFunctions sharedStorage;
    AddressManager addressManager;

    address public coordinatorAddress;
    address public governmentAddress;

    // Constructor sets the addresses for sharedStorage, AddressManager, Coordinator, and Government
    //constructor(address _sharedStorageAddress, address _addressManagerAddress, address _coordinatorAddress, address _governmentAddress) {
    constructor(address _sharedStorageAddress, address _addressManagerAddress, address _coordinatorAddress) {
        require(_sharedStorageAddress != address(0), "sharedStorage address cannot be zero.");
        require(_addressManagerAddress != address(0), "AddressManager address cannot be zero.");
        require(_coordinatorAddress != address(0), "Coordinator address cannot be zero.");
    //    require(_governmentAddress != address(0), "Government address cannot be zero.");

        sharedStorage = ICommonFunctions(_sharedStorageAddress);
        addressManager = AddressManager(_addressManagerAddress);
        coordinatorAddress = _coordinatorAddress;
    //    governmentAddress = _governmentAddress;
    }

    // Modifier to restrict function access to the company role
    modifier onlyCompany() {
        require(addressManager.isCompanyAddressAllowed(msg.sender), "Caller is not allowed: Company only.");
        _;
    }

     //Modifier to restrict function access to the government role
     modifier onlyGovernment() {
        require(msg.sender == governmentAddress, "Caller is not allowed: Government only.");
        _;
    }

    // Modifier to restrict function access to the coordinator role
    modifier onlyCoordinator() {
        require(msg.sender == coordinatorAddress, "Caller is not allowed: Coordinator only.");
        _;
    }
    event GovernmentAddressUpdated(address newAddress);

    function setGovernmentAddress(address _newAddress) public  {
        require(_newAddress != address(0), "New address cannot be zero.");
        governmentAddress = _newAddress;
        emit GovernmentAddressUpdated(_newAddress);
    }

    // Function to add a bus using the sharedStorage contract
    function addBus(uint256 model, string calldata vim_number, string calldata company_name, string calldata plate_number) external onlyCompany {
        sharedStorage.addBus(model, vim_number, company_name, plate_number, msg.sender);
    }

    function ForeWardToCoordinatorContract(uint256 busId) external onlyCompany {
        DataStr.BusItem memory bus = sharedStorage.getBusData(busId);
        require(bus.status != DataStr.BusStatus.Forward_To_Coordinator ||
        bus.status != DataStr.BusStatus.Rejected, "Bus already forwarded to Coordinator");
        
        sharedStorage.updateBusStatus(busId, DataStr.BusStatus.Forward_To_Coordinator, "Transferred to Coordinator", msg.sender);
        sharedStorage.updateOwnership(busId, coordinatorAddress);
}

    // Function to update the status of a bus
    function updateBusStatus(uint256 id, DataStr.BusStatus newStatus, string calldata note) external onlyCoordinator {
        sharedStorage.updateBusStatus(id, newStatus, note, msg.sender);
    }

    // Function to update the ownership of a bus
    function updateOwnership(uint256 id, address newOwner) external onlyGovernment {
        sharedStorage.updateOwnership(id, newOwner);
    }

    // Function to get the data of a specific bus by its ID
    function getBusData(uint256 id) external view returns (DataStr.BusItem memory) {
        return sharedStorage.getBusData(id);
    }

    // Additional functions for coordinator and government address management, and other logic as needed...
}