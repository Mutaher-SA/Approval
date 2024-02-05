// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "./ICommonFunctions.sol";
import "./AddressManager.sol"; // Assuming AddressManager is used for access control
import "./DataStructures.sol";
import "./ISharedStorage.sol"; // Interface for SharedStorage interactions

contract Company is ICommonFunctions {
    using Counters for Counters.Counter;
    Counters.Counter private _busId;

    AddressManager public addressManager; // Access control

    address public coordinatorAddress;
    address public governmentAddress;

    mapping(uint256 => BusItem) public buses; // for buses
    mapping(uint256 => address) private busOwners;  // for keep tracking of the ownership of each bus

    //constructor(address _addressManager) {
    //    addressManager = AddressManager(_addressManager);
    //}

    ISharedStorage public sharedStorage;

    constructor(address _coordinatorAddress, address _addressManagerAddress, address _sharedStorageAddress) {
        require(_coordinatorAddress != address(0), "Coordinator address cannot be zero.");
        require(_addressManagerAddress != address(0), "AddressManager address cannot be zero.");
        require(_sharedStorageAddress != address(0), "SharedStorage address cannot be zero.");
        coordinatorAddress = _coordinatorAddress;
        addressManager = AddressManager(_addressManagerAddress);
        sharedStorage = ISharedStorage(_sharedStorageAddress);
    }


    modifier onlyCompany() {
         require(addressManager.isCompanyAddressAllowed(msg.sender), "Company Not Allowed to access Im in COmapny Modifier");
        _;
    }

    modifier onlyGoverment() {
        require(addressManager.isGovernmentAddressAllowed(msg.sender), "Goverment address is Not Allowed to access");
        _;
    }

     modifier onlyCoordinator() {
        require(addressManager.isCoordinatorAddressAllowed(msg.sender), "Cooredinator Address is Not Allowed to access");
        _;
    }

    modifier AllRoles() {
    bool isAuthorized = addressManager.isCompanyAddressAllowed(msg.sender) ||
                        addressManager.isCoordinatorAddressAllowed(msg.sender) ||
                        addressManager.isGovernmentAddressAllowed(msg.sender);
    require(isAuthorized, "You are not  is not authorized!!!");
    _;
}


    function addBus(uint256 _model, string memory _vim_number, uint256 _company_number, string memory _plate_number) external override onlyCompany {
        require(_model>2014,"Bus Model shoudl be larger than 2014 Due to Goverment Regulations!");
        require(bytes(_vim_number).length>1,"Car _vim_number shoudl be larger than 24 chars");
        require(_company_number>0,"_company_number shoudl be larger than Zero");

        uint256 busId = _busId.current();
        _busId.increment();
        
        uint256 expireYear = _model + 10; // 10 years from current Model
        
        buses[busId] = BusItem({
            id: busId,
            model: _model,
            vim_number: _vim_number,
            company_number: _company_number,
            plate_number: _plate_number,
            expireYear: expireYear,
            status: BusStatus.Waiting,
            rejectNote: "",
            rejectBy: address(0),
            owner: msg.sender,
            creator: msg.sender,
            nftTokenId: 0 // Initialized to 0, to be updated upon government approval
        });

        emit BusCreated(busId, _model, _vim_number, _company_number, _plate_number, expireYear, BusStatus.Waiting, "", address(0), msg.sender, msg.sender, 0);
    }

    function getBusData(uint256 id) public view AllRoles returns (BusItem memory) {
    //require(id < _busId.current(), "The Bus does not exist!");
    return buses[id];
}

   function getBusStatus(uint256 busId) public view AllRoles returns  (BusStatus) {
        //require(busId >= 0 && busId < _busId.current(), "Invalid or non-existent bus ID");
        return buses[busId].status;
}

   function updateBusStatus(uint256 id, BusStatus newStatus) external override onlyCoordinator onlyGoverment {
        //require(id < _busId.current(), "The Bus does not exist!");
        buses[id].status = newStatus;
   }

     function forwardBusToCoordinator(uint256 busToForwardId) public onlyCompany {
        require(busToForwardId < _busId.current(), "The Bus does not exist!");
        buses[busToForwardId].status = BusStatus.ForwardToCoordinator;
        buses[busToForwardId].owner = coordinatorAddress;               // Update the owner to the coordinator's address
    }

    function setCoordinatorAddress(address _newCoordinatorContractAddress) external override onlyGoverment {
        coordinatorAddress = _newCoordinatorContractAddress;
    }

    function setGovermentAddress(address _newGovermentContractAddress) external override  onlyGoverment {
        governmentAddress = _newGovermentContractAddress;
    }

    function getBusesByStatus(BusStatus _status) public view override AllRoles returns (BusItem[] memory)  {
        uint256 totalBuses = _busId.current();
        uint256 count = 0;
        for (uint256 i = 0; i < totalBuses; i++) {
            if (buses[i].status == _status) {
                count++;
            }
        }

        BusItem[] memory busesByStatus = new BusItem[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < totalBuses; i++) {
            if (buses[i].status == _status) {
                busesByStatus[index] = buses[i];
                index++;
            }
        }
        return busesByStatus;
    }

     function updateBusStatusWithNote(uint256 _BusNo, BusStatus _newStatus, string memory _note, address _updatedBy) external override onlyGoverment onlyCoordinator {
        require(_BusNo < _busId.current(), "Bus does not exist.");
        require(
                addressManager.isCompanyAddressAllowed(msg.sender) || 
                addressManager.isGovernmentAddressAllowed(msg.sender), 
                "Not authorized to update bus status."
        );

        BusItem memory bus = buses[_BusNo];
        bus.status = _newStatus;
        bus.rejectNote = _note;
        bus.rejectBy = _updatedBy;
        
        emit BusStatusUpdated(_BusNo, _newStatus, _note, _updatedBy);
    }

   function updateOwnership(uint256 busId, address newOwner) external override {
    require(busId < _busId.current(), "The Bus does not exist!");
    require(newOwner != address(0), "New owner cannot be the zero address");
    
    // Check if the caller is the current owner or an authorized entity
    require(
        buses[busId].owner == msg.sender || 
        addressManager.isGovernmentAddressAllowed(msg.sender) || 
        msg.sender == coordinatorAddress,
        "Caller not authorized to update ownership"
    );

    // Update the bus owner
    buses[busId].owner = newOwner;
    
    // Emit an event for the ownership update (if you have an event defined for this)
    emit OwnershipUpdated(busId, newOwner);
}


    function _updateNftTokenId(uint256 _BusNo, uint256 nftTokenId) internal onlyGoverment {
        //require(_BusNo < _busId.current(), "Bus does not exist.");
        buses[_BusNo].nftTokenId = nftTokenId;
    }

    // Public function to be called by the Government contract
    function updateNftTokenIdByGovernment(uint256 busId, uint256 nftTokenId) external onlyGoverment {
        require(addressManager.isGovernmentAddressAllowed(msg.sender), "Unauthorized access");
        _updateNftTokenId(busId, nftTokenId);
    }

}
