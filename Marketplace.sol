// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract Marketplace is Ownable, ReentrancyGuard {
    using Address for address;

    struct Listing {
        address seller;
        uint256 tokenId;
        uint256 price;
        bool isActive;
    }

    event NFTListed(
        address indexed seller,
        uint256 indexed tokenId,
        uint256 price
    );
    event NFTBought(
        address indexed buyer,
        address indexed seller,
        uint256 indexed tokenId,
        uint256 price
    );
    event FundsWithdrawn(address indexed owner, uint256 amount);

    mapping(uint256 => Listing) public listings;
    uint256 public nextListingId;
    IERC721 public nftContract;

    constructor(address _nftContract) {
        require(_nftContract != address(0), "Invalid NFT contract address");
        nftContract = IERC721(_nftContract);
    }

    function listNFT(uint256 tokenId, uint256 price) external {
        require(price > 0, "Price must be greater than zero");
        nftContract.safeTransferFrom(msg.sender, address(this), tokenId);

        listings[nextListingId] = Listing({
            seller: msg.sender,
            tokenId: tokenId,
            price: price,
            isActive: true
        });

        emit NFTListed(msg.sender, tokenId, price);
        nextListingId++;
    }

    function buyNFT(uint256 listingId) external payable nonReentrant {
        Listing storage listing = listings[listingId];
        require(listing.isActive, "Listing is not active");
        require(msg.value == listing.price, "Incorrect price");

        listing.isActive = false;
        payable(listing.seller).transfer(msg.value);
        nftContract.safeTransferFrom(
            address(this),
            msg.sender,
            listing.tokenId
        );

        emit NFTBought(
            msg.sender,
            listing.seller,
            listing.tokenId,
            listing.price
        );
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        payable(owner()).transfer(balance);
        emit FundsWithdrawn(owner(), balance);
    }
}
