// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract DataStr{ 

enum BusStatus { 
                Waiting, 
                Approved, 
                Rejected, 
                Noted, 
                Forward_To_Coordinator, 
                Forward_To_Goverment,
                New_Bus
                }

    struct BusItem {
    uint256 id;
    uint256 model;
    string vim_number;
    uint256 company_ID;
    string plate_number;
    // uint256 expireYear; // This line is removed
    BusStatus status;
    string rejectNote;
    address rejectBy;
    address owner;
    address creator;
    uint256 nftTokenId;
    }


      //--------------------------Event declaration
    event BusCreated(
    uint256 indexed id,
    uint256 model,
    string vim_number,
    uint256 indexed company_ID,
    string plate_number,
    // uint256 expire_date, // Removed this parameter
    BusStatus indexed status,
    string rejectNote,
    address rejectBy,
    address owner,
    address creator,
    uint256 nftTokenId
    );


    event BusStatusUpdated(
        uint256 indexed id, 
        BusStatus indexed newStatus, 
        string note, 
        address updatedBy);
    
    
    event OwnershipUpdated(uint256 indexed busId, address indexed newOwner);
    event BusRejected(uint256 indexed id, string reason, address rejectedBy);
    event BusNoted(uint256 indexed id, string note, address notedBy);

}
