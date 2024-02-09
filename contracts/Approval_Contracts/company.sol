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
        require(addressManager.isCompanyAddressAllowed(msg.sender), "Company Address is not allowed: Company only.");
        _;
    }

     //Modifier to restrict function access to the government role
     modifier onlyGovernment() {
        require(msg.sender == governmentAddress, "Government Address is not allowed: Government only.");
        _;
    }

    event GovernmentAddressUpdated(address newAddress);
    event BusForwardedToCoordinator(uint256 indexed busId, address indexed by, address coordinatorAddress);

    function setGovernmentAddress(address _newAddress) public onlyGovernment {
        require(_newAddress != address(0), "New address cannot be zero.");
        governmentAddress = _newAddress;
        emit GovernmentAddressUpdated(_newAddress);
    }

    // Function to add a bus using the sharedStorage contract
    function addBus(
        uint256 model, 
        string calldata vim_number, 
        uint256 company_ID, 
        string calldata plate_number
    ) external {
        // Assume 'address(this)' is intended as the companyContractAddress
        sharedStorage.addBus(model, vim_number, company_ID, plate_number, msg.sender, address(this));
    }

    function forwardToCoordinatorContract(uint256 busId) external onlyCompany {
        // Ensure the bus ID is valid and the bus exists in the sharedStorage.
        require(busId > 0, "a message From Company Contract:  YOU Are LOOKING FOR a bus that does not exist!");

        // Retrieve the bus data from sharedStorage to ensure it exists and check its status.
        DataStr.BusItem memory bus = sharedStorage.getBusData(busId);
        
        // Check if the bus is already forwarded or rejected, to avoid redundant operations.
        require(bus.status != DataStr.BusStatus.Forward_To_Coordinator, "Bus already forwarded to Coordinator.");
        require(bus.status != DataStr.BusStatus.Rejected, "Bus is rejected and cannot be forwarded.");
        
        // Proceed to update the bus status and ownership since all checks passed.
        sharedStorage.updateBusStatus(busId, DataStr.BusStatus.Forward_To_Coordinator, "Transferred to Coordinator", msg.sender);
        sharedStorage.updateOwnership(busId, coordinatorAddress);

        //Optionally, emit an event here to log the successful forwarding operation.
        emit BusForwardedToCoordinator(busId, msg.sender, coordinatorAddress);
    }

   
    function getBusData(uint256 id) external view onlyCompany returns (DataStr.BusItem memory) {
        require(id > 0, "a message From Company Contract:  YOU Are LOOKING FOR a bus that does not exist!");
        return sharedStorage.getBusData(id);
    }

    function getMyCompanyBuses() external view returns (DataStr.BusItem[] memory) {
        require(address(sharedStorage) != address(0), "a message From Company Contract: SharedStorage contract is not set.");
        return sharedStorage.getBusesByCompany(msg.sender);
    }


        // This function replaces getNotedBuses with a more generic approach
    function getBusesByStatus(DataStr.BusStatus status) external view returns (DataStr.BusItem[] memory) {
        // Directly use sharedStorage's functionality to get buses by company (msg.sender) and status
        return sharedStorage.getBuses_Company_Status(msg.sender, status);
    }
   
    function getBusesByCompany(address companyAddress) external view returns (DataStr.BusItem[] memory) {
        return sharedStorage.getBusesByCompany(companyAddress);
    }

}