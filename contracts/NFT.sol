// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//opneZeppelin smart Contracts imports
import "@openzeppelin/contracts/token/ERC721/ERC721.sol"; 
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol"; //for counting nfts

//hardhat import for console loggging smarmcontracts
import "hardhat/console.sol";

//using uri stroage
contract NFT is ERC721URIStorage { //contract name and what openzepplin contract functionality is it inhereiting 
    using Counters for Counters.Counter; //using the counter utlitles
    Counters.Counter private _tokenIds; //allow contracts to keep up or track with the increments are counting
    address contractAddress; //variable for the contract address

    constructor (address marketplaceAddress) ERC721("Metaverse Tokens",  "METT") { //create ERC721 Token when contract is deployed
        contractAddress = marketplaceAddress; //store marketplace address as a variable in contractAddress
    }

    // create a token with metadata
    function createToken(string memory tokenURI) public returns (uint) {  //A Function that create a token and returns a uint
        _tokenIds.increment(); //For each token pass in tokenIds it increments or adds 1 to the value
        uint256 newItemId = _tokenIds.current(); //store the current value of the token in variable called newitemid


        //mint = making digital art apart of the ethereum network or turing it into a token
        _mint(msg.sender, newItemId);  //mint token using the sender adress and the newtokeid 
        _setTokenURI(newItemId, tokenURI); //An internal function from the uri contracts/basically and id
        setApprovalForAll(contractAddress, true); //give marketplace approval to transact
        return newItemId; 
     }
}
