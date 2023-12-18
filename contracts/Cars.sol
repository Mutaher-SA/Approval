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
        address payable OwnedBy,
        bool Car_State
    );

    event EvntSellingCar(uint256 CarID,address Newowner ,uint256 CarPrice);
//-------------------End Events Declerations------------------------------------------------------------------

    address AgencyOwner;
    constructor()
    {
        AgencyOwner= payable (msg.sender);
    }

    mapping(uint256 => Struct_Car) public MapCars;
    uint256[] public ListCars;

    modifier OnlyAgencyOwner() // for allow only agency owner to add cars
    {
        require(msg.sender == AgencyOwner,"Only The Agency Owner Can Add cars!!!");
        _;
    }

//------------------------Add New Car Data Function------------------------------------------------
    function AddCar(uint256 _Car_model,string memory _Car_color,uint256 _Car_Price,string memory _Car_Name) public OnlyAgencyOwner {
        _CurrentCarID.increment();
        //cars[_CurrentCarID.current()] = Car(_CurrentCarID.current(),_Car_model,_Car_color,_Car_Price,_Car_Name);
        Struct_Car memory newCar = Struct_Car(_CurrentCarID.current(),_Car_model,_Car_color,_Car_Price,_Car_Name,payable(AgencyOwner),true);
        MapCars[_CurrentCarID.current()] = newCar;
        ListCars.push(_CurrentCarID.current());
        emit EvntNewCarAdd(_CurrentCarID.current(), _Car_model, _Car_color, _Car_Price, _Car_Name,payable(AgencyOwner),true); 
    }

//------------------------View All Cars Function------------------------------------------------
    function AllCars() public view returns (Struct_Car[] memory) {
        
        //-----------This Code is written By me and its not Correct-----------------------------
        //uint SizeOfArrat = ListCars.length;
        //Struct_Car[] memory GetCars = new Struct_Car[](SizeOfArrat);
        //for (uint i = 0; i < SizeOfArrat; i++) {
        //    uint256 CarIDs = ListCars[i];
        //    GetCars[i] = MapCars[CarIDs];
        //}
        //return GetCars;

        //-------------This is the correct code written by Eng.Bahaa---------------------------
        uint256 sizeOfArray = _CurrentCarID.current();
        Struct_Car[] memory getCars= new Struct_Car[](sizeOfArray);

        for(uint256 i=1 ; i<=sizeOfArray ; i++)
        {
            getCars[i-1]=MapCars[i];
        }
        return getCars;

    }

//------------------------Sell Car And Pay Function------------------------------------------------
    function SellCar (uint256 _CarID) public payable 
    {
        //require(MapCars[_CarID].OwnedBy == msg.sender, "Car must be transferred By The Agency!!!");
        
        Struct_Car storage CarToSold = MapCars[_CarID];
        require(CarToSold.Car_State, "Car is already Sold");
        require(msg.value==CarToSold.Car_Price, "Wrong Car price");

        //CarToSold.OwnedBy = _TheBuyer;
        
        //---------------------NOT WORKING CODE--------------------------
        CarToSold.OwnedBy.transfer(msg.value);  
        CarToSold.OwnedBy=payable (msg.sender);            
        CarToSold.Car_State=false;              
        //---------------------END OF NOT WORKING CODE-------------------


        emit EvntSellingCar(_CarID , msg.sender , msg.value);
    }

}
