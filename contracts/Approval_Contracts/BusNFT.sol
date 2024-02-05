// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract BusNFT is ERC721URIStorage {
    uint256 private _nextTokenId = 1;
    address governmentAddress;

    mapping(uint256 => uint256) public busIdToNftTokenId;
    mapping(uint256 => uint256) public nftTokenIdToBusId;

    constructor() ERC721("BusNFT", "BSNFT") {}


    modifier onlyGovernment() {
        require(msg.sender == governmentAddress, "Caller is not the government.");
        _;
    }

     function setGovernmentAddress(address _govAddress) public {
        require(governmentAddress == address(0), "Government address already set.");
        governmentAddress = _govAddress;
    }

    function mint(uint256 busId, string memory tokenURI) public onlyGovernment returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        _mint(address(this), tokenId);
        _setTokenURI(tokenId, tokenURI);

        busIdToNftTokenId[busId] = tokenId;
        nftTokenIdToBusId[tokenId] = busId;

        return tokenId;
    }

    // Function to update government address if needed
    function updateGovernmentAddress(address newGovernmentAddress) public onlyGovernment {
        require(newGovernmentAddress != address(0), "Invalid new government address.");
        governmentAddress = newGovernmentAddress;
    }
}