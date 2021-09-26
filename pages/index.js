import { ethers } from 'ethers';
import { useEffect, useState } from 'react';
import axios from 'axios';
import Web3Modal from 'web3modal';

import { nftaddress, nftmarketaddress } from '../config';

//smart contracts ABI
import NFT from '../artifacts/contracts/NFT.sol/NFT.json';
import Market from '../artifacts/contracts/NFTMarket.sol/NFTMarket.json';

export default function Home() {
  const [nfts, setnfts] = useState([]); //Hide and show NFT'S
  const [loadingState, setLoadingState] = useState('not-loaded'); //Show and hide UI

  //call smart contract to load Nft's
  useEffect(() => {
    loadNFTs(); //call load nft's function
  }, []);

  async function loadNFTs() {
    /*create a generic provider to */
    const provider = new ethers.providers.JsonRpcProvider(
      'https://polygon-mumbai.infura.io/v3/cb08e784b77443ef8178a1d7bdb10652'
    );
    const tokenContract = new ethers.Contract(nftaddress, NFT.abi, provider); //get NFT sMART CONTRACT
    const marketContract = new ethers.Contract(
      nftmarketaddress,
      Market.abi,
      provider
    ); // get Market contract
    const data = await marketContract.fetchMarketItems(); //get all the market items

    /*
     *  map over items returned from smart contract and format
     *  them as well as fetch their token metadata
     */
    const items = await Promise.all(
      data.map(async (i) => {
        //looping thought the data via the smart contracts
        const tokenUri = await tokenContract.tokenURI(i.tokenId); //get token uri
        const meta = await axios.get(tokenUri); //meta data is stored in the ipfs || fetch the data by getting the uri
        let price = ethers.utils.formatUnits(i.price.toString(), 'ether'); //format price to show less digits
        let item = {
          //items details
          price,
          tokenId: i.tokenId.toNumber(),
          seller: i.seller,
          owner: i.owner,
          image: meta.data.image,
          name: meta.data.name,
          description: meta.data.description,
        };
        return item;
      })
    );
    setnfts(items); //update nft array
    setLoadingState('loaded'); //show UI
  }

  async function buyNft(nft) {
    /* needs the user to sign the transaction, so will use Web3Provider and sign it */
    const web3Modal = new Web3Modal();
    const connection = await web3Modal.connect(); //connect to wallet
    const provider = new ethers.providers.Web3Provider(connection); //connection the ethereum network
    const signer = provider.getSigner(); //sign and execute transaction
    const contract = new ethers.Contract(nftmarketaddress, Market.abi, signer); //get marketplace Contract

    /* user will be prompted to pay the asking process to complete the transaction */
    const price = ethers.utils.parseUnits(nft.price.toString(), 'ether'); //loop through the nfts prices
    const transaction = await contract.createMarketsale(
      //transcation between the contract and buyer
      nftaddress,
      nft.tokenId,
      { value: price }
    );
    await transaction.wait(); //wait for the transation to happen
    loadNFTs(); //update user UI || The NFT the buyer pruchase should be gone
  }
  if (loadingState === 'loaded' && !nfts.length)
    return <h1 className="px-20 py-10 text-3xl"> No items in marketplace </h1>;

  return (
    <div className="flex justify-center">
      <div className="px-4" style={{ maxWidth: '1600px' }}>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 pt-4">
          {
            //SINGLE items display
            nfts.map((nft, i) => (
              <div key={i} className="border shadow rounded-x1 overflow-hidden">
                <img src={nft.image} />
                <div className="p-4">
                  <p
                    style={{ height: '64px' }}
                    className="text-2x1 font-semibold"
                  >
                    {' '}
                    {nft.name}{' '}
                  </p>
                  <div style={{ height: '70px', overflow: 'hidden' }}>
                    <p className="text-gray-400">{nft.description}</p>
                  </div>
                </div>
                <div className="p-4 bg-black">
                  <p className="text-2-1 mb-4 font-bold text-white">
                    {nft.price} ETH
                  </p>
                  <button
                    className="w-full bg-pink-500 text-white font-bold py-2 px-12 rounded"
                    onClick={() => buyNft(nft)}
                  >
                    {' '}
                    BUY{' '}
                  </button>
                </div>
              </div>
            ))
          }
        </div>
      </div>
    </div>
  );
}
