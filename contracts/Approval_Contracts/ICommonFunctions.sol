
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "./DataStr.sol";

interface ICommonFunctions {
       
    // Function to add a new bus entry
    function addBus(
        uint256 model, 
        string calldata vim_number,
        string calldata company_name, 
        string calldata plate_number,
        address creator
    ) external;


    // Function to update the status of a bus
    function updateBusStatus(
        uint256 id, 
        DataStr.BusStatus newStatus, 
        string calldata note, 
        address updatedBy
    ) external;

    // Function to update the ownership of a bus
    function updateOwnership(
        uint256 id, 
        address newOwner
    ) external;

    // Function to get data of a specific bus by its ID
    function getBusData(
        uint256 id
    ) external view returns (DataStr.BusItem memory);

    function getBusStatus(uint256 busId) external view returns (DataStr.BusStatus);

    function updateNft(uint256 busId, uint256 nftTokenId) external;

}
