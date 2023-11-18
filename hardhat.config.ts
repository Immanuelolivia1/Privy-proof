import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

require("dotenv").config();

const config: HardhatUserConfig = {
  solidity: "0.8.18",
  networks: {
    celo: {
      url: "https://forno.celo.org",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 42220,
    },
    //   mumbai_testnet: {
    //     url: "https://rpc-mumbai.maticvigil.com", //URL of the RPC node for mumbai
    //     accounts: [process.env.PRIVATE_KEY], //Your private key starting with "0x"
    //     //Make sure you have enough funds in this wallet to deploy the smart contract
    //   },
  },
};

export default config;
