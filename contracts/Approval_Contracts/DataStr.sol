
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract DataStr{ 

enum BusStatus { Waiting, Approved, Rejected, Noted, ForwardToCoordinator , ForwardToHTMC }

    struct BusItem {
    uint256 id;
    uint256 model;
    string vim_number;
    uint256 company_number;
    string plate_number;
    uint256 expireYear;
    BusStatus status;
    string rejectNote;
    address rejectBy;
    address owner;
    address creator;
    uint256 nftTokenId; // Added field for the NFT token ID
    }

      //--------------------------Event declaration
    event BusCreated(
        uint256 indexed id,
        uint256 model,
        string vim_number,
        uint256 company_number,
        string plate_number,
        uint256 expire_date,
        BusStatus status,
        string rejectNote,
        address rejectBy,
        address owner,
        address creator,
        uint256 nftTokenId
    );

    event BusStatusUpdated(
        uint256 indexed id, 
        BusStatus newStatus, 
        string note, 
        address updatedBy);
    
    event OwnershipUpdated(uint256 indexed busId, address indexed newOwner);
}