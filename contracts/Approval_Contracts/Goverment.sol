// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./ICommonFunctions.sol";
import "./AddressManager.sol";
import "./company.sol";
import "./BusNFT.sol";

contract Government  {
    Company public companyContract; // Assuming you have a direct reference to the Company contract
    uint256 private nextTokenId;
    AddressManager public addressManager;
    BusNft public busNftContract;

     constructor(address _busNftContractAddress, address _companyContractAddress, address _addressManagerAddress) {
        busNftContract = BusNft(_busNftContractAddress);
        companyContract = Company(_companyContractAddress);
        addressManager = AddressManager(_addressManagerAddress); // Initialize the AddressManager contract instance
    }

    modifier onlyGoverment() {
        require(addressManager.isGovernmentAddressAllowed(msg.sender), "Caller is not an authorized coordinator.");
        _;
    }

    // Function to approve a bus and mint an NFT for it
   function approveBusAndMintNFT(uint256 busId, uint256 companyId, string memory nftTokenURI) public onlyGoverment returns (uint256) {
    // Retrieve the current status of the bus to ensure it is ForwardToHTMC
    ICommonFunctions.BusStatus currentStatus = companyContract.getBusStatus(busId);
    require(currentStatus == ICommonFunctions.BusStatus.ForwardToHTMC, "Bus is not ready to be approved");
    // Ensure the bus ID is valid (not empty)
    require(busId > 0, "Invalid bus ID");

    // Mint the NFT for the approved bus and get the new token ID
    uint256 newTokenId = busNftContract.mintNFTForApprovedBus(address(companyContract), nftTokenURI, busId, companyId);
    
    // Notify the Company contract to update the NFT token ID for the bus
    companyContract.updateNftTokenIdByGovernment(busId, newTokenId);

    return newTokenId;
}

    
}

    // Additional Government contract functions...

