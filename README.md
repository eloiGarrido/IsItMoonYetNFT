# Is It Moon Yet: Basic NFT project

This project is a learning experiment heavily influenced by `karalabe.eth`'s I'm The Chad contract.
`Is It Moon Yet` is a singleton NFT for the person who's always on top of the price chart, willing to transact the closer to the moon the price gets. It can be used as a standard NFT, but anyone can reown it when the token price, obtained from a Uniswap V3 pool, is higher than the last time it was reowned. The NFT is part vanity item and part tag game.

A deployed example of this contract can be found in the Polygon network at address `0xeFcA09b638fa520b542204cD339E85cbB639fBF8`

- Polygonscan: https://polygonscan.com/address/0xeFcA09b638fa520b542204cD339E85cbB639fBF8
- OpenSea: https://opensea.io/assets/matic/0xefca09b638fa520b542204cd339e85cbb639fbf8/1

## Local development

Run the following command to deploy a local network with a snapshot from mainnet contracts, required to obtain uniswap's pool price.

```shell
npx hardhat node --fork https://eth-mainnet.alchemyapi.io/v2/<ALCHEMY_KEY>
```

Replace `/scripts/deploy.js` address with the pool of your liking and execute

```shell
npx hardhat compile
npm run deploy:local
```

To deploy `isItMoonYet.sol` contract into your local network.
The npm script should populate `scripts/contractAddress.txt` with the locally deployed contract address. However, if you are observing odd compiler errors when interacting with the contract make sure the address is set properly.

### Tasks

- `npx hardhat accounts`: Prints the list of accounts.
- `npx hardhat price`: Prints the uniswap pool price.
- `npx hardhat uri`: Prints the current NFT URI.
