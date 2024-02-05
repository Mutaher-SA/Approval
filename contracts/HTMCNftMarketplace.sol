 // SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./HTMCNft.sol";
//import "./Helper_Address_Lists.sol";
import "./AddressArrayUtils.sol";

contract HTMCNftMarketplace is ReentrancyGuard 
{
//TO DO CRUD OPERTIONS BY ADMIN
uint256 private  AVALIABLE_YEARS = 10;

using Counters for Counters.Counter;
Counters.Counter private busId;

address superAdmin;

constructor()
{
    superAdmin = msg.sender;
}

enum BusStatus 
{
    WATING,APPROVED,REJECT,NOTED,FOREWARD_TO_HTMC
}

struct BusItem 
{
   uint256 id;
   uint256 model;
   string vim_number;
   uint256 company_number;
   string plate_number;
   uint256 nft_token_id;
   uint256 expire_date;
   BusStatus status;
   address owner;
   address creatore;
}

event BusCreateted 
(  
   uint256 id,
   uint256 model,
   string vim_number,
   uint256 company_number,
   string plate_number,
   uint256 nft_token_id,
   uint256 expire_date,  
   BusStatus status,
   address owner,
   address creatore
);
    mapping (uint256=>BusItem) private busList;
    //Add Bus to our System

    address [] private companyList;  

    using AddressArrayUtils for address[];
    //address[] public chkAddress;
    //MODIFIRES
    //address   [] private governanceList;  
    //address   [] private Cordimatore List;  

modifier onlySuperAdmin()
{
    require(msg.sender == superAdmin,"Dont have permission to do this operation");
    _;
}
modifier onlyCompanyAdmin()
{
    //=>
    //require(addressArrayItemExist(msg.sender,companyList) == true,"Dont have permission to do this operation");
    //_;
    bool adressIsThere= AddressArrayUtils.addressArrayItemExist(msg.sender,companyList);
    require(adressIsThere == true,"Dont have permission to do this operation");
    _;
}

function addCompany(address companyAddress) public  onlySuperAdmin  returns (bool){
    require(companyAddress != address(0),"Dont have permission to do this operation");

    companyList.push(companyAddress);
    return true;
}
function addBus(uint256 _model,string  memory _vim_number,uint256 _company_number,uint256 tokenId,string memory _plate_number,   address  nftContract)public onlyCompanyAdmin  nonReentrant   {
    require(_model>2013,"Car Model shoudl be larger than 2013");
    require(bytes(_vim_number).length>1,"Car _vim_number shoudl be larger than 24 chars");
    require(_company_number>0,"_company_number shoudl be larger than Zero");
    require(nftContract !=address(0),"Address should not be equal 0x0 or nulled");

    //TO DO =>2015 =>2026 NOT WORK 
    uint256 expireYear = _model - AVALIABLE_YEARS ;
    busId.increment();
    uint256 id = busId.current();
    //NFT ID
    BusStatus status = BusStatus.WATING;
    busList[id] = BusItem(id,_model,_vim_number,_company_number,_plate_number,tokenId,expireYear,status,address(this),msg.sender);
    IERC721(nftContract).transferFrom(msg.sender,address(this),tokenId);
    emit BusCreateted(id,_model,_vim_number,_company_number,_plate_number,tokenId,expireYear,status,address(this),msg.sender);
}

function getSingleBus(uint256 id) public  view returns  (BusItem memory)
{
    require(id <= busId.current(),"Id Not Found");
    return busList[id];
}

//Govermint 

function changeBusStatusToAPPROVED(uint256 id) public  view returns  (BusItem memory)
{

    require(id <= busId.current(),"Id Not Found");

    BusItem memory changeBus = busList[id];

    changeBus.status = BusStatus.APPROVED;

    return busList[id] ;
}

//HELPER FUNTIONS
//function addressArrayItemExist(address userAdrress,address [] memory list) public  pure  returns (bool){
//require(userAdrress !=address(0),"Address should not be equal 0x0 or nulled");

//    for(uint256 i =0;i<list.length;i++){
//        if(list[i]==userAdrress){
//            return true;
//        }
//        else {
//               return  false;
//        }
//    }
//}

//Get Bus Lisdt WIth Pagination
function getBusListForCompanyOwner(uint256 pageNumber, uint256 pageSize,address companyOwner)public view returns (BusItem[] memory){
        require(pageNumber > 0, "Page number should be greater than 0");
        require(pageSize > 0, "Page size should be greater than 0");


        uint myCurrentIndex = 0;
        BusItem [] memory listValidBusItem = new BusItem[](busId.current());

        for(uint i=0;i<busId.current();i++){

            if(busList[i+1].creatore == companyOwner){

                uint curreentId = i+1;

            BusItem storage currentItem = busList[curreentId];
            listValidBusItem[myCurrentIndex]=currentItem;
            myCurrentIndex +=1;


            }
        }


        //??// listValidBusItem [1000];

        uint256 startIndex = (pageNumber - 1) * pageSize;
        uint256 endIndex = startIndex + pageSize;


      BusItem [] memory busResult = new BusItem[](endIndex-startIndex);

      for(uint256 i =startIndex;i<endIndex;i++){
        busResult[i] = listValidBusItem[i];
      }


return busResult;


}
  
}