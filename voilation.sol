// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract BusViolationsContract {
    struct Violation {
        uint256 companyId;
        string busCompany;
        uint256 busCompanyNumber;
        string busPlateNumber;
        string location;
        uint256 numberOfPassengers;
        string violationsIssuer;
        uint256 dateOfViolation;
        string category;
    }

    enum Category { A, B }

    address public owner;
    mapping(address => bool) public authorizedTeams;
    mapping(address => bool) public authorizedMembers;
    mapping(uint256 => Violation[]) public violationsByCompany;
    uint256 public roadCharge;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event AuthorizedTeamAdded(address teamAddress);
    event AuthorizedMemberAdded(address memberAddress);
    event ViolationReported(uint256 companyId, string category);
    event RoadChargeUpdated(uint256 newRoadCharge);

    constructor(uint256 _roadCharge) {
        owner = msg.sender;
        roadCharge = _roadCharge;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthorized: Only owner can perform this action");
        _;
    }

    modifier onlyAuthorizedMember() {
        require(authorizedMembers[msg.sender], "Unauthorized: Only member can perform this action");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner cannot be the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function addAuthorizedTeam(address teamAddress) public onlyOwner {
        authorizedTeams[teamAddress] = true;
        emit AuthorizedTeamAdded(teamAddress);
    }

    function addAuthorizedMember(address memberAddress) public onlyAuthorizedMember {
        authorizedMembers[memberAddress] = true;
        emit AuthorizedMemberAdded(memberAddress);
    }

    function reportViolation(
        uint256 _companyId,
        string memory _busCompany,
        uint256 _busCompanyNumber,
        string memory _busPlateNumber,
        string memory _location,
        uint256 _numberOfPassengers,
        string memory _violationsIssuer,
        uint256 _dateOfViolation,
        string memory _category
    ) public onlyAuthorizedMember {
        Violation memory newViolation = Violation({
            companyId: _companyId,
            busCompany: _busCompany,
            busCompanyNumber: _busCompanyNumber,
            busPlateNumber: _busPlateNumber,
            location: _location,
            numberOfPassengers: _numberOfPassengers,
            violationsIssuer: _violationsIssuer,
            dateOfViolation: _dateOfViolation,
            category: _category
        });

        violationsByCompany[_companyId].push(newViolation);
        emit ViolationReported(_companyId, _category);
    }

    function getViolationsForCompany(uint256 _companyId) public view returns (Violation[] memory) {
        return violationsByCompany[_companyId];
    }

    function updateRoadCharge(uint256 _newRoadCharge) public onlyOwner {
        roadCharge = _newRoadCharge;
        emit RoadChargeUpdated(_newRoadCharge);
    }

    function calculateTotalPenaltyA(uint256 companyId) public view returns (uint256) {
        uint256 countA = 0;
        for (uint i = 0; i < violationsByCompany[companyId].length; i++) {
            if (keccak256(bytes(violationsByCompany[companyId][i].category)) == keccak256(bytes("A"))) {
                countA++;
            }
        }
        return countA * 5 * roadCharge;
    }

    function calculateTotalPenaltyB(uint256 companyId) public view returns (uint256) {
        uint256 countB = 0;
        for (uint i = 0; i < violationsByCompany[companyId].length; i++) {
            if (keccak256(bytes(violationsByCompany[companyId][i].category)) == keccak256(bytes("B"))) {
                countB++;
            }
        }
        return countB * 2 * roadCharge;
    }
}
