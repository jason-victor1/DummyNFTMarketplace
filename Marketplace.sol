// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract Marketplace is ReentrancyGuard, Ownable {
    struct Listing {
        address seller;
        uint256 tokenId;
        uint256 price;
        bool isActive;
    }

    mapping(uint256 => Listing) public listings;
    IERC721 public immutable nftContract; // Updated to 'immutable'

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

    constructor(address _nftContract) {
        nftContract = IERC721(_nftContract); // Set immutable variable in constructor
    }

    function listNFT(uint256 tokenId, uint256 price) external nonReentrant {
        require(price > 0, "Price must be greater than zero");
        require(
            nftContract.ownerOf(tokenId) == msg.sender,
            "You are not the owner"
        );
        require(
            nftContract.isApprovedForAll(msg.sender, address(this)),
            "Marketplace not approved"
        );

        listings[tokenId] = Listing(msg.sender, tokenId, price, true);
        emit NFTListed(msg.sender, tokenId, price);
    }

    function buyNFT(uint256 tokenId) external payable nonReentrant {
        Listing storage listing = listings[tokenId];
        require(listing.isActive, "Listing is not active");
        require(msg.value == listing.price, "Incorrect price");

        // Update state before external call
        listing.isActive = false;

        // Secure payment
        Address.sendValue(payable(listing.seller), msg.value);

        // Transfer NFT
        nftContract.safeTransferFrom(listing.seller, msg.sender, tokenId);

        emit NFTBought(msg.sender, listing.seller, tokenId, msg.value);
    }

    function withdraw() external onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        // Transfer balance to the contract owner
        Address.sendValue(payable(owner()), balance);

        emit FundsWithdrawn(owner(), balance);
    }
}

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool);
}
