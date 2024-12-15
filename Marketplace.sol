// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Marketplace is ReentrancyGuard {
    struct Listing {
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 price;
    }

    mapping(uint256 => Listing) public listings;
    uint256 public nextListingId;

    event Listed(
        address indexed seller,
        address indexed nftContract,
        uint256 indexed tokenId,
        uint256 price
    );
    event Purchased(
        address indexed buyer,
        address indexed nftContract,
        uint256 indexed tokenId
    );

    function listNFT(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public {
        require(price > 0, "Price must be greater than zero");

        listings[nextListingId] = Listing(
            msg.sender,
            nftContract,
            tokenId,
            price
        );
        emit Listed(msg.sender, nftContract, tokenId, price);

        ++nextListingId; // Optimized increment
    }

    function buyNFT(uint256 listingId) public payable nonReentrant {
        Listing memory listing = listings[listingId];
        require(msg.value == listing.price, "Incorrect payment");

        delete listings[listingId];
        emit Purchased(msg.sender, listing.nftContract, listing.tokenId); // Added missing event
    }
}
