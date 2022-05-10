const hre = require("hardhat");

async function main() {
  const IsItMoonYet = await hre.ethers.getContractFactory("IsItMoonYet");

  const isItMoonYet = await IsItMoonYet.deploy(
    "0x07a6e955ba4345bae83ac2a6faa771fddd8a2011" // Uniswap pool address
  );
  await isItMoonYet.deployed();
  console.log("IsItMoonYet deployed to:", isItMoonYet.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
