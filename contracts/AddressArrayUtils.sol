// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

library AddressArrayUtils 
{
    function addressArrayItemExist(address userAddress, address[] memory list) external pure returns (bool) {
        require(userAddress != address(0), "Address should not be equal to 0x0 or null");

        for (uint256 i = 0; i < list.length; i++) {
            if (list[i] == userAddress) {
                return true;
            }
        }
        return false;
    }
}
