// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.2;

import "./ICommonFunctions.sol";
import "./AddressManager.sol";

contract Coordinator {
    ICommonFunctions public companyContract;
    AddressManager public addressManager;

    // Assuming a mapping to store notes for buses, if applicable.
    mapping(uint256 => string) public busNotes;
    //-----------Events------------------------------
    event BusRejected(uint256 busId, string note, address updatedBy);
    event BusNoted(uint256 busId, string note, address updatedBy);
    
    struct CoordinatorBusItem {
        ICommonFunctions.BusStatus status;
        string note;
        address updatedBy;
    }

    mapping(uint256 => CoordinatorBusItem) public coordinatorBusItems;


    constructor(address _companyContractAddress, address _addressManagerAddress) {
        require(_companyContractAddress != address(0), "Company contract address cannot be zero.");
        require(_addressManagerAddress != address(0), "AddressManager contract address cannot be zero.");
        companyContract = ICommonFunctions(_companyContractAddress);
        addressManager = AddressManager(_addressManagerAddress);
    }

    modifier onlyAuthorizedCoordinator() {
        require(addressManager.isCoordinatorAddressAllowed(msg.sender), "Caller is not an authorized coordinator.");
        _;
    }

     // Retrieve the data for a single bus by its ID
    function getBusData(uint256 busId) public view returns (ICommonFunctions.BusItem memory) {
        return companyContract.getBusData(busId);
    }

    // Retrieve all buses that match a specific status
    function getBusesByStatus(ICommonFunctions.BusStatus status) public view returns (ICommonFunctions.BusItem[] memory) {
        return companyContract.getBusesByStatus(status);
    }

    function forwardBusToGovernment(uint256 busId) public onlyAuthorizedCoordinator {
        // Retrieve the bus data to check its current status
        ICommonFunctions.BusItem memory bus = companyContract.getBusData(busId);
        
        // Ensure that the bus is in a state that allows it to be forwarded to the government
        require(bus.status == ICommonFunctions.BusStatus.ForwardToCoordinator, "Bus cannot be forwarded to the government in its current state.");

        // Update the bus status to indicate it has been forwarded to the government
        companyContract.updateBusStatus(busId, ICommonFunctions.BusStatus.ForwardToHTMC);
    }

    // Function to set a new address for the company contract
    // This might be necessary if the company contract is upgraded or changed
    function setCompanyContractAddress(address _newCompanyContractAddress) external onlyAuthorizedCoordinator {
        require(_newCompanyContractAddress != address(0), "New company contract address cannot be zero.");
        companyContract = ICommonFunctions(_newCompanyContractAddress);
    }

    function rejectBus(uint256 busId, string memory note) public onlyAuthorizedCoordinator {
        ICommonFunctions.BusItem memory bus = getBusData(busId);
        require(bus.status == ICommonFunctions.BusStatus.Waiting || bus.status == ICommonFunctions.BusStatus.Noted, "Bus cannot be rejected in its current state.");
        // Update bus status and note directly in the Company contract
        companyContract.updateBusStatusWithNote(busId, ICommonFunctions.BusStatus.Rejected, note, msg.sender);
        emit BusRejected(busId, note, msg.sender);
    }


    function noteBus(uint256 busId, string memory note) public onlyAuthorizedCoordinator {
    // Similar update for noting a bus
        coordinatorBusItems[busId] = CoordinatorBusItem({
        status: ICommonFunctions.BusStatus.Noted,
        note: note,
        updatedBy: msg.sender
    });
    emit BusNoted(busId, note, msg.sender);
}

     // Function to reject a bus with a reason
    //function rejectBus(uint256 busId, string memory note) public onlyAuthorizedCoordinator {
    //    ICommonFunctions.BusItem memory bus = companyContract.getBusData(busId);
    //    require(bus.status == ICommonFunctions.BusStatus.Waiting || bus.status == ICommonFunctions.BusStatus.Noted, "Bus cannot be rejected in its current state.");

        // This may require changes to your ICommonFunctions interface and companyContract implementation
      //  companyContract.updateBusStatusWithNote(busId, ICommonFunctions.BusStatus.Rejected, note, msg.sender);
    //}

    // Function to mark a bus as noted, potentially reusing the rejectNote field for simplicity
    //function noteBus(uint256 busId, string memory note) public onlyAuthorizedCoordinator {
      //  ICommonFunctions.BusItem memory bus = companyContract.getBusData(busId);
       // require(bus.status == ICommonFunctions.BusStatus.Waiting, "Bus cannot be noted in its current state.");

        // Reuse updateBusStatusWithNote for noting as well, indicating the action and actor
        //companyContract.updateBusStatusWithNote(busId, ICommonFunctions.BusStatus.Noted, note, msg.sender);
    //}
}
      

