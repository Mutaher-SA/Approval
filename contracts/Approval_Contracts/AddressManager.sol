// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.2;

contract AddressManager {
    address public owner;
    mapping(address => bool) public companyAddresses;
    mapping(address => bool) public coordinatorAddresses;
    mapping(address => bool) public governmentAddresses;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    // Company address management
    function addCompanyAddress(address _address) public onlyOwner {
        companyAddresses[_address] = true;
    }

    function removeCompanyAddress(address _address) public onlyOwner {
        companyAddresses[_address] = false;
    }

    function isCompanyAddressAllowed(address _address) public view returns (bool) {
        return companyAddresses[_address];
    }

    // Coordinator address management
    function addCoordinatorAddress(address _address) public onlyOwner {
        coordinatorAddresses[_address] = true;
    }

    function removeCoordinatorAddress(address _address) public onlyOwner {
        coordinatorAddresses[_address] = false;
    }

    function isCoordinatorAddressAllowed(address _address) public view returns (bool) {
        return coordinatorAddresses[_address];
    }

    // Government address management
    function addGovernmentAddress(address _address) public onlyOwner {
        governmentAddresses[_address] = true;
    }

    function removeGovernmentAddress(address _address) public onlyOwner {
        governmentAddresses[_address] = false;
    }

    function isGovernmentAddressAllowed(address _address) public view returns (bool) {
        return governmentAddresses[_address];
    }
}