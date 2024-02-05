 // SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";



contract HTMCNft is ERC721URIStorage {

 using Counters for Counters.Counter;
    Counters.Counter private nftTokenId;

//ONLY WORK WITH MY MARKETPLACE Contract

address marketPlaceContractAddress;


    constructor( address _marketPlaceContractAddress)ERC721("carsNFT","CA"){
        marketPlaceContractAddress=_marketPlaceContractAddress;
    }


    function mintNFT(string memory nftTokenURI) public  returns (uint256){

        nftTokenId.increment();
        uint256 id = nftTokenId.current();

        _mint(msg.sender, id);
        _setTokenURI(id, nftTokenURI);
        setApprovalForAll(marketPlaceContractAddress, true);


     return id;
    }

    function transferToken( address from, address to, uint256 tokenId)external {

        require(ownerOf(tokenId)==from,"Only Owner admin can transfer token");

        _transfer(from, to, tokenId);
    }

    function getMarketplaceContractAddress () public view returns(address){


    return marketPlaceContractAddress;

   
}


}