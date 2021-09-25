const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('NFTMarket', function () {
  it('should create and execute market sales', async function () {
    /* deploy the marketplace*/
    const NFTMarket = await ethers.getContractFactory('NFTMarket');
    const market = await NFTMarket.deploy();
    await market.deployed();
    const marketAddress = market.address; //market address as a varible

    //deploy nft contract
    const NFT = await ethers.getContractFactory('NFT');
    const nft = await NFT.deploy(marketAddress);
    await nft.deployed();
    const nftContractAddress = nft.address; //set nft Address as a varible

    //listing price
    let listingPrice = await market.getListingPrice(); //fetch listing price
    listingPrice = listingPrice.toString(); //convert lisitng price to string

    //how much the nft cost
    const auctionPrice = ethers.utils.parseUnits('100', 'ether'); //

    /* create two tokens */
    await nft.createToken('https://www.mytokenlocation.com');
    await nft.createToken('https://www.mytokenlocation2.com');

    //list the items to the market place
    await market.createMarketItem(nftContractAddress, 1, auctionPrice, {
      value: listingPrice,
    }); //listed the item in the market place buy giving it args
    await market.createMarketItem(nftContractAddress, 2, auctionPrice, {
      value: listingPrice,
    });

    const [_, buyerAddress] = await ethers.getSigners(); //dont want buyer and seller to be the same person

    await market
      .connect(buyerAddress)
      .createMarketsale(nftContractAddress, 1, { value: auctionPrice }); //selling the nft and transfering funds to the buyer

    let items = await market.fetchMarketItems();

    items = await Promise.all(
      items.map(async (i) => {
        const tokenUri = await nft.tokenURI(i.tokenId);
        let items = {
          price: i.price.toString(),
          tokenId: i.tokenId.toString(),
          seller: i.seller,
          owner: i.owner,
          tokenUri,
        };
        return items;
      })
    );

    console.log(`items: `, items);
  });
});
