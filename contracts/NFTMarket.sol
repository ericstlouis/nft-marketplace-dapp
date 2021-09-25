// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//opneZeppelin smart Contracts imports
import "@openzeppelin/contracts/token/ERC721/ERC721.sol"; //nft 
import "@openzeppelin/contracts/utils/Counters.sol"; //for counting nfts
import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; //security to stop reenctancy and other constant attack

import "hardhat/console.sol";


contract NFTMarket is ReentrancyGuard {
  using Counters
  for Counters.Counter;
  Counters.Counter private _itemIds; // increment /track the items Id
  Counters.Counter private _itemsSold; //increment /track the items sold

  address payable owner; //determine who is owner of the smartcontract because owner will get commison fee
  uint256 listingPrice = 0.025 ether; //price to list your nft

  constructor() {
    owner = payable(msg.sender);
  }

  //list all of the market item stats/ or info
  struct MarketItem {
    uint itemId;
    address nftContract;
    uint256 tokenId;
    address payable seller;
    address payable owner;
    uint price;
    bool sold;
  }

  // linking the marketItem to idToMarketItem //marketItem will be fetch when call the marketitem Id
  mapping(uint256 => MarketItem) private idTomarketItem;

  //event = info to send to frontend 
  event MarketItemCreated(
    uint indexed itemId,
    address indexed nftContract,
    uint256 indexed tokenId,
    address seller,
    address owner,
    uint256 price,
    bool sold
  );

  function getListingPrice() public view returns(uint) {
    return listingPrice;
  }

  //place item for sale in the marektplace
  function createMarketItem(address nftContract, uint256 tokenId, uint256 price) public payable nonReentrant { //get the token adress, token ID and the price for the seller
    require(price > 0, "price must be at leat 1 wei"); //the price must be greater the 1 wei
    require(msg.value == listingPrice, "price must equal to lising price"); //the seller value must be equal to the lising price

    _itemIds.increment(); // add value to the current 
    uint256 itemId = _itemIds.current(); //set the current value as a varible

    idTomarketItem[itemId] = MarketItem(
      itemId,
      nftContract,
      tokenId,
      payable(msg.sender),
      payable(address(0)),
      price,
      false
    );

    //transfer ownrship of the nft to this contract //it kind of of like the middleman
    IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

    //when fucntion will send event data to front-end
    emit MarketItemCreated(itemId, nftContract, tokenId, msg.sender, address(0), price, false);
  }


  /* Creates the sale of a marketplace item */
  /* Transfers ownership of the item, as well as funds between parties */
  function createMarketsale(address nftContract, uint256 itemId) public payable nonReentrant {
    uint price = idTomarketItem[itemId].price; //map price to the itemid
    uint tokenId = idTomarketItem[itemId].tokenId; //map to to the tokenId
    require(msg.value == price, "please submit the asking price in order to compete the purchase"); //must equal to the value to transact

    idTomarketItem[itemId].seller.transfer(msg.value); //transfer the value to the seller address
    IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId); //sending the contract to the buyer
    idTomarketItem[itemId].owner = payable(msg.sender); //giving the nft a new owner which is the buyer
    idTomarketItem[itemId].sold = true; //selling the ethereum blockchain that it is sold
    _itemsSold.increment(); //telling the markertplace that the item is sold
    payable(owner).transfer(listingPrice); // pay the owener of the contract commison of the owner
  }

  // returns all the unsold items 
  function fetchMarketItems() public view returns(MarketItem[] memory) { //return an array of market items
    uint itemCount = _itemIds.current(); //track the current items as a varibles
    uint unsoldItemCOunt = _itemIds.current() - _itemsSold.current(); //count the unsold items
    uint currentIndex = 0; //an empty variable

    MarketItem[] memory items = new MarketItem[](unsoldItemCOunt); //creating a new empty array that will be the length of unsolditemcount
    for (uint i = 0; i < itemCount; i++) { //loop through all the items
      if (idTomarketItem[i + 1].owner == address(0)) { //check if toTomarketItem has an owner 
        uint currentId = idTomarketItem[i + 1].itemId; //id of currenitem were checking
        MarketItem storage currentItem = idTomarketItem[currentId]; //a variable getting the currentId
        items[currentIndex] = currentItem; //getting an empry arrat
        currentIndex += 1; //increment the currentIndex tot he array above
      }
    }
    return items;
  }

  //function to fetch owner nft

  function fetchMyNFTS() public view returns(MarketItem[] memory) { //returning an array of the nft you own
    uint totalItemCount = _itemIds.current(); //count the total number of item
    uint itemCount = 0; //a variable that set value of itemcount to zero
    uint currentIndex = 0; //a variable that set value of currentIndex to zero

    for (uint i = 0; i < totalItemCount; i++) { // loop through all the items
      if (idTomarketItem[i + 1].owner == msg.sender) { //check if idtomarket has anowner
        itemCount += 1; //increment 1 on item count
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount); //a new array that is the length of the itemCount
    for (uint i = 0; i < totalItemCount; i++) { //loop through total items created
      if (idTomarketItem[i + 1].owner == msg.sender) { // check if nft has owner
        uint currentId = i + 1; //increment 1  
        MarketItem storage currentItem = idTomarketItem[currentId]; //make a permanet varible that get the id
        items[currentIndex] = currentItem; //mapping
        currentIndex += 1; //increment current index
      }
    }
    return items;
  }

  //return only the nft's the user created
  function fetchItemsCreated() public view returns(MarketItem[] memory) { //get all the the items the user created 
    uint totalItemCount = _itemIds.current();
    uint itemCount = 0;
    uint currentIndex = 0;

    for (uint i = 0; i < totalItemCount; i++) {
      if (idTomarketItem[i + 1].seller == msg.sender) {
        itemCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint i = 0; i < totalItemCount; i++) {
      if (idTomarketItem[i + 1].seller == msg.sender) {
        uint currentId = i + 1;
        MarketItem storage currentItem = idTomarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }
}