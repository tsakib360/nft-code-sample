// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract NftBuySellerc721 is ERC721, ERC721Enumerable, ERC721URIStorage {
    using SafeMath for uint256;

    uint public constant mintPrice = 0;

    mapping(address => mapping(uint256 => Listing)) public listings;
    mapping(address => uint256) public balances;

    struct Listing {
        uint256 price;
        address seller;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
    internal
    override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721, ERC721URIStorage)
    returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721,ERC721Enumerable)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    constructor() ERC721("YTMinter", "YTM") {}

    function mint(string memory _uri) public payable {
        uint256 mintIndex = totalSupply();
        _safeMint(msg.sender, mintIndex);
        _setTokenURI(mintIndex, _uri);
    }


    function addListing(uint256 price, address contractAddr, uint256 tokenId) public {
        ERC721 token = ERC721(contractAddr);
        require(token.balanceOf(msg.sender) > 0, "caller must own given token!");
        require(token.isApprovedForAll(msg.sender, address(this)), "contract must be approved!");

        listings[contractAddr][tokenId] = Listing(price, msg.sender);
    }

    function purchase(address contractAddr, uint256 tokenId, uint256 amount) public payable {
        Listing memory item = listings[contractAddr][tokenId];
        require(msg.value >= item.price * amount, "Insufficient funds sent!");
        balances[item.seller] += msg.value;

        ERC721 token = ERC721(contractAddr);
        token.safeTransferFrom(item.seller, msg.sender, tokenId);
    }

    function withdraw(uint256 amount, address payable destAddr) public {
        require(amount <= balances[msg.sender], "Insufficient funds!");

        destAddr.transfer(amount);
        balances[msg.sender] -= amount;
    }
}