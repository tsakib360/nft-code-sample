// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract NftBuySell is ERC1155 {
    uint256 public constant CHARIZARD = 0;
    string public name = "TS Collection New";

    mapping(address => mapping(uint256 => Listing)) public listings;
    mapping(address => uint256) public balances;

    struct Listing {
        uint256 price;
        address seller;
    }

    constructor() ERC1155("") {}

    function mint(string memory _uri) public payable {
        _setURI(_uri);
        _mint(msg.sender, CHARIZARD, 100, "");
    }

    function addListing(uint256 price, address contractAddr, uint256 tokenId) public {
        ERC1155 token = ERC1155(contractAddr);
        require(token.balanceOf(msg.sender, tokenId) > 0, "caller must own given token!");
        require(token.isApprovedForAll(msg.sender, address(this)), "contract must be approved!");

        listings[contractAddr][tokenId] = Listing(price, msg.sender);
    }

    function purchase(address contractAddr, uint256 tokenId, uint256 amount) public payable {
        Listing memory item = listings[contractAddr][tokenId];
        require(msg.value >= item.price * amount, "Insufficient funds sent!");
        balances[item.seller] += msg.value;

        ERC1155 token = ERC1155(contractAddr);
        token.safeTransferFrom(item.seller, msg.sender, tokenId, amount, "");
    }

    function withdraw(uint256 amount, address payable destAddr) public {
        require(amount <= balances[msg.sender], "Insufficient funds!");

        destAddr.transfer(amount);
        balances[msg.sender] -= amount;
    }
}