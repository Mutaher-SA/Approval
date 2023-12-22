// SPDX-License-Identifier: GPL-3.0

import "@openzeppelin/contracts/utils/Counters.sol";
pragma solidity >=0.8.2 <0.9.0;

contract Bank_System
{
    using Counters for Counters.Counter;
    
    struct Stc_Account
    {
        uint256 cust_id;
        string cust_name;
        uint256 cust_balance;
        bool cust_state;
    }
    address public band_admin;
    mapping (address=>Stc_Account) public Map_cust;
    Counters.Counter _CurrentCustID;

    event EvtNewwCust(uint256 customerId, address indexed customerAddress, string name, uint256 amount);
    event EvtAddMoney(uint256 customerId, address indexed customerAddress, uint256 amount);
    event EvtWithdraw(uint256 customerId, address indexed customerAddress, uint256 amount);
    constructor()
    {
        band_admin=msg.sender;
    }

    receive() external payable 
    { 
        require(msg.value>1 ether, "You are trying to withdraw NOTHING!!! ");        
        AddMoney();
    }
    //receive() public payable 
    //{
    //    require(msg.value > 1 ether, "The amount should be larger than 1 ");
        //AddCustomer(_CurrentCarID.current(), cust_name ,cust_Balanace,cust_Address);
    //}


    function NewAccount(string memory _cust_name) public 
    {
        require(Map_cust[msg.sender].cust_id == 0, "Account already exists");

        _CurrentCustID.increment(); 
        Map_cust[msg.sender] = Stc_Account(_CurrentCustID.current(), _cust_name, 0, true);
        
        emit EvtNewwCust(_CurrentCustID.current(), msg.sender, _cust_name,0); 
    }

//---------------------------------------function to Add New customer
    function AddMoney() public payable 
    {
        require(Map_cust[msg.sender].cust_id != 0, "No Account data found!!! ");
        Map_cust[msg.sender].cust_balance+=msg.value;  
        emit EvtAddMoney(Map_cust[msg.sender].cust_id, msg.sender, msg.value);
    }
//---------------------------------------function to get balance
    function GetCust_Balance() public view returns (uint256)
    {
        return Map_cust[msg.sender].cust_balance;
    }
//---------------------------------------function to withdraw
    function Cust_Withdraw (uint256 _Amount) public payable  
    {
        require(Map_cust[msg.sender].cust_id != 0, "No Account data found!!! ");
        require(Map_cust[msg.sender].cust_balance >= _Amount, "You are trying to withdraw money you don't have!!! ");
        require(_Amount>0, "You are trying to withdraw NOTHING!!! ");

        payable (msg.sender).transfer(_Amount);
        Map_cust[msg.sender].cust_balance-=msg.value;
        
        emit EvtWithdraw(Map_cust[msg.sender].cust_id, msg.sender,_Amount);

    }
}
