// SPDX-License-Identifier: GPL-3.0

import "@openzeppelin/contracts/utils/Counters.sol";
pragma solidity >=0.8.2 <0.9.0;

contract CarAgency {
    using Counters for Counters.Counter;
    
    struct Struct_Car {
        uint256 Car_id;
        uint256 Car_model;
        string Car_color;
        uint256 Car_Price;
        string Car_Name;
        address payable OwnedBy;
        bool Car_State;
    }

    //Struct_Car[] public Ag_Car;
    //uint256 public CarID;
    Counters.Counter _CurrentCarID;

//-------------------Start Events Declerations------------------------------------------------------------------
     event EvntNewCarAdd(
        uint256 Car_id,
        uint256 Car_model,
        string Car_color,
        uint256 Car_Price,
        string Car_Name,
        address OwnedBy,
        bool Car_State
    );

    event EvntSellingCar(uint256 CarID, uint256 CarPrice);
//-------------------End Events Declerations------------------------------------------------------------------

    address AgencyOwner;
    constructor()
    {
        AgencyOwner= msg.sender;
    }

    mapping(uint256 => Struct_Car) public MapCars;
    uint256[] public ListCars;

    modifier OnlyAgencyOwner() // for allow only agency owner to add cars
    {
        require(msg.sender == AgencyOwner,"Only The Agency Owner Can Add cars!!!");
        _;
    }

//------------------------Add New Car Data Function------------------------------------------------
    function AddCar(uint256 _Car_model,string memory _Car_color,uint256 _Car_Price,string memory _Car_Name, address,bool) public OnlyAgencyOwner {
        _CurrentCarID.increment();
        //cars[_CurrentCarID.current()] = Car(_CurrentCarID.current(),_Car_model,_Car_color,_Car_Price,_Car_Name);
        Struct_Car memory newCar = Struct_Car(_CurrentCarID.current(),_Car_model,_Car_color,_Car_Price,_Car_Name,payable (AgencyOwner),true);
        MapCars[_CurrentCarID.current()] = newCar;
        ListCars.push(_CurrentCarID.current());
        emit EvntNewCarAdd(_CurrentCarID.current(), _Car_model, _Car_color, _Car_Price, _Car_Name, AgencyOwner,true); 
    }

//------------------------View All Cars Function------------------------------------------------
    function AllCars() public view returns (Struct_Car[] memory) {
        uint SizeOfArrat = ListCars.length;
        Struct_Car[] memory GetCars = new Struct_Car[](SizeOfArrat);
        for (uint i = 0; i < SizeOfArrat; i++) {
            uint256 CarIDs = ListCars[i];
            GetCars[i] = MapCars[CarIDs];
        }
        return GetCars;
    }

//------------------------Sell Car And Pay Function------------------------------------------------
    function SellCar (uint256 _CarID, address _TheBuyer, uint256 _CarPrice) public  payable 
    {
        //require(MapCars[_CarID].OwnedBy == msg.sender, "Car must be transferred By The Agency!!!");
        
        Struct_Car memory CarToSold = MapCars[_CarID];
        require(CarToSold.Car_State, "Car is already Sold");
        require(CarToSold.Car_Price >= _CarPrice, "Wrong Car value ");

        //CarToSold.OwnedBy = _TheBuyer;
        CarToSold.OwnedBy.transfer(CarToSold.Car_Price);
        CarToSold.OwnedBy=payable (_TheBuyer);
        CarToSold.Car_State=false;
        emit EvntSellingCar(_CarID, _CarPrice);
    }

}
