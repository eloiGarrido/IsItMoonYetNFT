const fs = require("fs");
require("@nomiclabs/hardhat-waffle");
require("dotenv").config({ path: ".env" });
require("@nomiclabs/hardhat-etherscan");

const ALCHEMY_POLYGON = process.env.ALCHEMY_POLYGON;
const POLYGONSCAN_KEY = process.env.POLYGONSCAN_KEY;
const MATIC_PRIVATE_KEY = process.env.MATIC_PRIVATE_KEY;
// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

async function getContract() {
  const contractAddress = fs
    .readFileSync("./scripts/contractAddress.txt")
    .toString()
    .trim();
  const IsItMoonYet = await ethers.getContractFactory("IsItMoonYet");
  return await IsItMoonYet.attach(contractAddress);
}

task("price", "Prints the uniswap pool price", async () => {
  // Fetch the contract address from the config
  const contract = await getContract();
  const getPairPrice = await contract.getPairPrice();
  console.log(`Pair price: ${getPairPrice}`);
});

task("uri", "Prints the uri of the NFT", async () => {
  const contract = await getContract();
  const uri = await contract.tokenURI(1);
  console.log(`Token URI: ${uri}`);
});

module.exports = {
  defaultNetwork: "localhost",
  networks: {
    localhost: {
      forking: {
        url: "https://eth-mainnet.alchemyapi.io/v2/H35X6FNT3pet5bbx_toH2vK55eh4GAx9",
      },
    },
    polygon: {
      url: ALCHEMY_POLYGON,
      accounts: [MATIC_PRIVATE_KEY],
    },
  },
  solidity: {
    version: "0.8.7",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  etherscan: {
    apiKey: POLYGONSCAN_KEY,
  },
};
