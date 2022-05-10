// contracts/IsItMoonYet.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";

contract IsItMoonYet is ERC721 {
    // author is the creator of the contract and the entity that receives any
    // reown royalties. The author can also lower (never increase) the reown
    // royalty and can relinquish the contract to a new address.
    address public author;

    // reownPrice is the token price that needs to be exceeded in order to reown
    // the NFT from its previous owner.
    uint256 public reownPrice;

    // reownRoyalty is the amount of Wei that needs to be paid to the contract
    // author as a royalty to reown.
    uint256 public reownRoyalty;

    // moonSeekers is the list of accounts that have reowned the NFT.
    address[] public moonSeekers;

    // pool is the UniswapV3 pool that is used to track the token price.
    IUniswapV3Pool public immutable pool;

    /* Custom Errors */
    error HigherPriceNotReachedError(uint256 reownPrice, uint256 _price);
    error RoyaltyPriceNotReachedError(uint256 reownRoyalty, uint256 value);
    error OnlyAuthorError();
    error HigherRoyaltyNotAllowedError(uint256 reownRoyalty, uint256 royalty);
    error WrongAddressError(address _address);
    error FailedTransactionError();

    modifier onlyAuthor() {
        if (msg.sender != author) revert OnlyAuthorError();
        _;
    }

    event NewOwner(address newOwner, uint256);

    // The constructor creates a single token for the IsItMoonYet NFT collection,
    // owned by the deployer, reownable at the current pool price.
    constructor(address _pool) ERC721("Is It Moon Yet", "IIMY") {
        pool = IUniswapV3Pool(_pool);
        author = msg.sender;
        reownPrice = 0;
        reownRoyalty = 10 ether;

        _mint(msg.sender, 1);
        moonSeekers.push(msg.sender);
    }

    function getPairPrice() public view returns (uint256 price) {
        (uint160 sqrtPriceX96, , , , , , ) = pool.slot0();
        return
            (uint256(sqrtPriceX96) * (uint256(sqrtPriceX96)) * (1e18)) >>
            (96 * 2);
    }

    // reown attempts to take the NFT away from its current owner and give it
    // to the caller - if and only if - the current price is higher than the
    // previous reown level.
    function reown() public payable {
        if (msg.value < reownRoyalty)
            revert RoyaltyPriceNotReachedError(reownRoyalty, msg.value);

        uint256 _price = getPairPrice();
        if (_price <= reownPrice)
            revert HigherPriceNotReachedError(reownPrice, _price);

        reownPrice = _price;
        // Burn and recreate the NFT to ensure no internal state is leaked from
        // the previous owner (singleton token with ID=1)
        _burn(1);
        _mint(msg.sender, 1);
        moonSeekers.push(msg.sender);
        emit NewOwner(msg.sender, _price);
    }

    // reprice can be used by the contract author to lower the royalties paid
    // upon reown. Royalties can never be increased.
    function reprice(uint256 _royalty) public onlyAuthor {
        if (_royalty > reownRoyalty)
            // Only allow to reprice to a lower value
            revert HigherRoyaltyNotAllowedError(reownRoyalty, _royalty);

        reownRoyalty = _royalty;
    }

    // reauthor can be used by the contract author to transfer ownership of the
    // contract (not the NFT!) to a new address.
    function reauthor(address newAuthor) public onlyAuthor {
        if (newAuthor == address(0)) revert WrongAddressError(newAuthor); // Cannot reauthor to the same address

        author = newAuthor;
    }

    // withdraw can be used by the contract author to withdraw any accumulated royalties.
    function withdraw() public onlyAuthor {
        (bool success, ) = payable(author).call{value: address(this).balance}(
            ""
        );
        if (!success) revert FailedTransactionError();
    }

    // tokenURI generates an SVG data URI to display as a vanity image for the NFT.
    function tokenURI(uint256) public view override returns (string memory) {
        string memory mooners = "";
        for (uint256 i = 0; i < moonSeekers.length; i++) {
            mooners = string(
                abi.encodePacked(
                    itoa(i + 1),
                    ". ",
                    mooners,
                    atoa(moonSeekers[i]),
                    "%5Cn"
                )
            );
        }
        return
            string(
                abi.encodePacked(
                    metaPrefix,
                    mooners,
                    metaInfix,
                    imgPrefix,
                    itoa(reownPrice),
                    imgSuffix,
                    metaSuffix
                )
            );
    }

    // Image generation

    string metaPrefix =
        "data:application/json;charset=UTF-8,%7B%22name%22%3A %22Is It Moon Yet%22,%22description%22%3A %22Is It Moon Yet is a singleton NFT for the person who's always on top of the price chart, willing to transact the closer to the moon the price gets. It can be used as a standard NFT, but anyone can reown it when the token price, obtained from Uniswap V3 pool, is higher than the last time it was reowned. The NFT is a vanity item and tag game%5Cn%5CnTo support the contract creator, each reown entails a royalty that needs to be paid %28see%20%60reownRoyalty%60%29. Support goes to coffee addiction%5Cn%5CnMoon Seekers%3A%5Cn";
    string metaInfix = "%22,%22image%22%3A %22";
    string metaSuffix = "%22%7D";
    string imgPrefix =
        "data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' width='512' height='256'%3e%3cdefs%3e%3clinearGradient id='gf' y2='256' gradientUnits='userSpaceOnUse'%3e%3cstop offset='0' stop-color='%236dff2e' /%3e%3cstop offset='0.14' stop-color='%23003002' /%3e stop offset='0.29' stop-color='%2341ebc9' /%3e%3cstop offset='0.43' stop-color='%23e630d3' /%3e stop offset='0.57' stop-color='%23420275' /%3e%3cstop offset='0.71' stop-color='%2388005f' /%3e stop offset='0.86' stop-color='%23550061' /%3e%3cstop offset='1' stop-color='%2306005c' /%3e%3c/linearGradient%3e%3c/defs%3e%3crect width='512' height='256' fill='url(%23gf)'/%3e%3ctext x='50%25' y='40%25' text-anchor='middle' font-family='Comic Sans' font-size='48px' fill='%23efe'%3eIs It Moon Yet%3c/text%3e%3ctext x='50%25' y='75%25' text-anchor='middle' font-family='Comic Sans' font-size='32px' fill='%23efe'%3eMinted @";
    string imgSuffix = " MATIC/USDC%3c/text%3e%3c/svg%3e";

    // itoa converts an int to a string.
    function itoa(uint256 n) internal pure returns (string memory) {
        if (n == 0) {
            return "0";
        }
        bytes memory reversed = new bytes(100);
        uint256 len = 0;
        while (n != 0) {
            uint256 r = n % 10;
            n = n / 10;
            reversed[len++] = bytes1(uint8(48 + r));
        }
        bytes memory buf = new bytes(len);
        for (uint256 i = 0; i < len; i++) {
            buf[i] = reversed[len - i - 1];
        }
        return string(buf);
    }

    // atoa converts an address to a string.
    function atoa(address a) internal pure returns (string memory) {
        bytes memory addr = abi.encodePacked(a);
        bytes memory alphabet = "0123456789abcdef";

        bytes memory buf = new bytes(2 + addr.length * 2);
        buf[0] = "0";
        buf[1] = "x";
        for (uint256 i = 0; i < addr.length; i++) {
            buf[2 + i * 2] = alphabet[uint256(uint8(addr[i] >> 4))];
            buf[3 + i * 2] = alphabet[uint256(uint8(addr[i] & 0x0f))];
        }
        return string(buf);
    }
}
