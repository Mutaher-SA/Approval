// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

interface Bus_NFTInterface {
    function mintNFT(string memory nftTokenURI) external returns (uint256);
    function transferToken(address from, address to, uint256 tokenId) external;
 
}
