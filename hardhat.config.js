require('@nomiclabs/hardhat-waffle');
require('dotenv').config();


// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

module.exports = {
  defaultNetwork: 'mumbai',
  networks: {
    hardhat: {
      chainId: 1337,
    },
     mumbai: {
     url: process.env.MUMBAI_URL,
    accounts: [process.env.PRIVATE_KEY]
     },
  },
  solidity: '0.8.4',
};
