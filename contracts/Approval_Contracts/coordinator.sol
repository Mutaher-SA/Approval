// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.2;

import "./ICommonFunctions.sol";
import "./AddressManager.sol";
import "./DataStr.sol"; // For BusStatus and BusItem struct

contract Coordinator {
    ICommonFunctions public sharedStorage;
    AddressManager public addressManager;
    address public governmentAddress;
    address public CompanyAddress;

    event BusForwardedToGovernment(uint256 busId);
    event BusRejected(uint256 busId, string note, address updatedBy);
    event BusNoted(uint256 busId, string note, address updatedBy);

    constructor(address _sharedStorageAddress, address _addressManagerAddress, address _governmentAddress) {
        require(_sharedStorageAddress != address(0), "SharedStorage contract address cannot be zero.");
        require(_addressManagerAddress != address(0), "AddressManager contract address cannot be zero.");
        require(_governmentAddress != address(0), "Government address cannot be zero.");
        sharedStorage = ICommonFunctions(_sharedStorageAddress);
        addressManager = AddressManager(_addressManagerAddress);
        governmentAddress = _governmentAddress;
    }

    modifier onlyCoordinator() {
        require(addressManager.isCoordinatorAddressAllowed(msg.sender), "Caller is not an authorized coordinator.");
        _;
    }

    // Retrieve the data for a single bus by its ID
    function getBusData(uint256 busId) public view returns (DataStr.BusItem memory) {
        return sharedStorage.getBusData(busId);
    }
    
    function getBusesByCompany(address companyAddress) external view returns (DataStr.BusItem[] memory) {
        return sharedStorage.getBusesByCompany(companyAddress);
    }

    function forwardToGoverment(uint256 busId) external onlyCoordinator {
        require(sharedStorage.getBusStatus(busId) != DataStr.BusStatus.Forward_To_Coordinator, "Bus is not in a state that can be forwarded to Government.");

        sharedStorage.updateBusStatus(busId, DataStr.BusStatus.Forward_To_Goverment, "Transferred to Goverment", msg.sender);
        sharedStorage.updateOwnership(busId, governmentAddress);
    }

    function rejectBus(uint256 busId, string memory note) public onlyCoordinator {
        DataStr.BusItem memory bus = getBusData(busId);
        require(bus.status == DataStr.BusStatus.Forward_To_Coordinator || 
                bus.status == DataStr.BusStatus.New_Bus
                , "Bus cannot be Noted in its current state.");
        sharedStorage.updateBusStatus(busId, DataStr.BusStatus.Rejected, note, msg.sender);
        sharedStorage.updateOwnership(busId, CompanyAddress);
        emit BusRejected(busId, note, msg.sender);
    }

    function noteBus(uint256 busId, string memory note) public onlyCoordinator {
        DataStr.BusItem memory bus = getBusData(busId);
        require(bus.status == DataStr.BusStatus.Forward_To_Coordinator || 
                bus.status == DataStr.BusStatus.New_Bus
                , "Bus cannot be Noted in its current state.");
        sharedStorage.updateBusStatus(busId, DataStr.BusStatus.Noted, note, msg.sender);
        sharedStorage.updateOwnership(busId, CompanyAddress);
        emit BusNoted(busId, note, msg.sender);
    }

    function getBusesOwnedByCoordinator() external view returns (DataStr.BusItem[] memory) {
        uint256 totalBuses = sharedStorage.getTotalNumberOfBuses(); 
        // Temporary array to hold all buses (max possible size to start)
        DataStr.BusItem[] memory tempArray = new DataStr.BusItem[](totalBuses);
        uint256 count = 0;

        // Iterate through all buses, checking ownership
        for (uint256 i = 1; i <= totalBuses; i++) {
            DataStr.BusItem memory bus = sharedStorage.getBusData(i);
            if (bus.owner == address(this)) { // Check if the bus is owned by this contract
                tempArray[count] = bus;
                count++;
            }
        }

        // Create a fitted array for the result
        DataStr.BusItem[] memory busesOwnedByCoordinator = new DataStr.BusItem[](count);
        for (uint256 i = 0; i < count; i++) {
            busesOwnedByCoordinator[i] = tempArray[i];
        }

    return busesOwnedByCoordinator;
}

    function setCompanyContractAddress(address _newCompanyContractAddress) external onlyCoordinator {
        require(_newCompanyContractAddress != address(0), "New company contract address cannot be zero.");
        CompanyAddress = _newCompanyContractAddress;
    }
    
    function setSharedStorageAddress(address _newSharedStorageAddress) external onlyCoordinator {
        require(_newSharedStorageAddress != address(0), "New shared storage contract address cannot be zero.");
        sharedStorage = ICommonFunctions(_newSharedStorageAddress);
    }
}
