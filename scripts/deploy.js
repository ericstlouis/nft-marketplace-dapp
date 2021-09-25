
const hre = require("hardhat");

async function main() {
  //marketplace contract
  const marketFactory = await hre.ethers.getContractFactory('NFTMarket');
  const market = await marketFactory.deploy();
  await market.deployed();
  console.log('marketplace is deployed to:', market.address);

  // nft contract
  const NFTfactory = await hre.ethers.getContractFactory('NFT');
  const nft = await NFTfactory.deploy(market.address);
  await nft.deployed();
  console.log('nft is deployed to:', nft.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
