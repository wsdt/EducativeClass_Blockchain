// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./AddRecover.sol";
import "./LinearlyAssigned.sol";

contract Wavect is ERC721, LinearlyAssigned, AddRecover {

    string public baseURI;

    constructor(string memory baseURI_)
        ERC721("Wavect", "WACT")
        LinearlyAssigned(100, 0)
    {
        baseURI = baseURI_;
    }

    // TODO:
    // 1. MaxWallet
    // 2.
    function mint(address to_) external {
        _mint(to_, nextToken());
    }

    function setBaseURI(string memory baseURI_) external onlyOwner {
        baseURI = baseURI_;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }
}
