const hre = require("hardhat");

async function main() {
  const IsItMoonYet = await hre.ethers.getContractFactory("IsItMoonYet");

  const isItMoonYet = await IsItMoonYet.deploy(
    "0xa374094527e1673a86de625aa59517c5de346d32" //Address to uniswap pool
  );
  await isItMoonYet.deployed(); // Contract deployed at 0xeFcA09b638fa520b542204cD339E85cbB639fBF8
  console.log("IsItMoonYet deployed to:", isItMoonYet.address);
  console.log("Sleeping.....");
  await sleep(10000);

  // Verify the contract after deploying
  await hre.run("verify:verify", {
    address: isItMoonYet.address,
    constructorArguments: ["0xa374094527e1673a86de625aa59517c5de346d32"],
  });
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
