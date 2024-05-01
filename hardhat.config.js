require("@nomicfoundation/hardhat-toolbox");
require('@openzeppelin/hardhat-upgrades');

require("dotenv").config();

const accounts = process.env.PRIVATE_KEY

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.16",

  networks: {
    development: {
      url: "http://127.0.0.1:8545",
      network_id: "*"
    },
    bsc: {
      url: "https://bsc-mainnet.nodereal.io/v1/cc5edee862e544ad93e090f0550e4633",
      accounts,
      chainId: 56,
      live: true,
      saveDeployments: true,
    },
    bscTestnet: {
      url: "https://data-seed-prebsc-1-s1.bnbchain.org:8545",
      accounts,
      chainId: 97,
      live: true,
      saveDeployments: true,
      tags: ["staging"],
      gasMultiplier: 2,
      gasPrice: 10000000000,
    },
    opbnb: {
      url: "https://opbnb-mainnet.nodereal.io/v1/6779bcb4331f49d5955166c109711294",
      accounts,
      chainId: 204,
      live: true,
      saveDeployments: true,
    },
    chiliz: {
      url: "https://rpc.ankr.com/chiliz",
      accounts,
      chainId: 88888,
      live: true,
      saveDeployments: true,
    },
    chiliz_spicy: {
      // url: "https://spicy-rpc.chiliz.com/",
      url: "https://88882.rpc.thirdweb.com",
      accounts,
      chainId: 88882,
      live: true,
      saveDeployments: true,
      tags: ["staging"],
      gasMultiplier: 2,
      // gasPrice: 2500e9,
    },
  },
  etherscan: {
    // https://docs.bnbchain.org/opbnb-docs/docs/tutorials/opbnbscan-verify-hardhat-truffle
    apiKey: {
      bsc: process.env.ETHERSCAN_API_KEY,
      bscTestnet: process.env.ETHERSCAN_API_KEY,
      opbnb: "6779bcb4331f49d5955166c109711294",//replace your nodereal API key
      chiliz: "chiliz", // apiKey is not required, just set a placeholder
      chiliz_spicy: "chiliz_spicy", // apiKey is not required, just set a placeholder
    },
    customChains: [
      {
        network: "chiliz",
        chainId: 88888,
        urls: {
          apiURL: "https://api.routescan.io/v2/network/mainnet/evm/88888/etherscan",
          browserURL: "https://chiliscan.com"
        }
      },
      {
        network: "chiliz_spicy",
        chainId: 88882,
        urls: {
          apiURL: "https://api.routescan.io/v2/network/testnet/evm/88882/etherscan",
          browserURL: "https://testnet.chiliscan.com"
        }
      },
      {
        network: "opbnb",
        chainId: 204, // Replace with the correct chainId for the "opbnb" network
        urls: {
          apiURL: "https://open-platform.nodereal.io/6779bcb4331f49d5955166c109711294/op-bnb-mainnet/contract",
          browserURL: "https://opbnbscan.com/",
        },
      },
    ]
  },
  sourcify: {
    // Disabled by default
    // Doesn't need an API key
    enabled: true
  },
};
