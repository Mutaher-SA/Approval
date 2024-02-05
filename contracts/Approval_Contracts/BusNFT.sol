// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./AddressManager.sol"; // Import the AddressManager contract interface

contract BusNft is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _nftTokenId;

    address public addressManagerAddress;
    mapping(uint256 => uint256) private busIdToTokenId; // Maps a bus ID to an NFT token ID
    mapping(uint256 => uint256[]) private companyToTokenIds; // Maps a company ID to a list of NFT token IDs

    constructor(address _addressManagerAddress) ERC721("BusNFT", "BUS") {
        addressManagerAddress = _addressManagerAddress;
    }

    modifier onlyGovernment() {
        require(AddressManager(addressManagerAddress).isGovernmentAddressAllowed(msg.sender), "Caller is not an authorized government.");
        _;
    }

    // Function to mint NFT for an approved bus and associate it with a company
    function mintNFTForApprovedBus(address to, string memory tokenURI, uint256 busId, uint256 companyId) public onlyGovernment returns (uint256) {
        _nftTokenId.increment();
        uint256 newItemId = _nftTokenId.current();

        _mint(to, newItemId);
        _setTokenURI(newItemId, tokenURI);

        // Store the mapping from busId to the new token ID
        busIdToTokenId[busId] = newItemId;

        // Associate the new token ID with the companyId
        companyToTokenIds[companyId].push(newItemId);

        return newItemId;
    }

    // Function to get the NFT token ID for an approved bus
    function getNftForApprovedBus(uint256 busId) public view returns (uint256) {
        require(busIdToTokenId[busId] != 0, "No NFT for this bus");
        return busIdToTokenId[busId];
    }

    // Function to get NFTs associated with a company
    function getNftsByCompany(uint256 companyId) public view returns (uint256[] memory) {
        return companyToTokenIds[companyId];
    }


}
