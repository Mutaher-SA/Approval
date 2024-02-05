// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract testcontract {

    string public myName="I Love Blockchain";

    address [] public AdminsAdresses = [0x3F486A757f46f5fd90889105235C0f6A99B40F51,0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, 0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678, 0xdD870fA1b7C4700F2BD7f44238821C26f7392148, 0x17F6AD8Ef982297579C203069C1DbfFE4348c372];

    function changeMyName(string memory inputName) public returns  (string memory)  {
        myName=inputName;
        return myName;
    } 
}