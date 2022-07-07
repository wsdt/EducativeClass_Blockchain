// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "base64-sol/base64.sol";
import "./AddRecover.sol";
import "./LinearlyAssigned.sol";

contract Wavect is ERC721, LinearlyAssigned, AddRecover {

    string public baseURI;
    uint256 public maxWallet;
    string private _metadataDescr;
    string private _metadataName;
    bool public revealed;

    /// @dev Used to specifically reward active community members, etc.
    mapping(uint256 => uint256) rank;

    constructor(string memory baseURI_)
        ERC721("Wavect", "WACT")
        LinearlyAssigned(100, 0)
    {
        maxWallet = 1;
        baseURI = baseURI_;
    }

    function mint() external {
        require(balanceOf(_msgSender()) < maxWallet, "Already minted");
        _mint(_msgSender(), nextToken());
    }

    function setMaxWallet(uint256 maxWallet_) external onlyOwner {
        maxWallet = maxWallet_;
    }
    function reveal(bool reveal_) external onlyOwner {
        revealed = reveal_;
    }

    /// @dev BaseURI is used for the image itself in this case, since the metadata itself lives on-chain
    function setBaseURI(string memory baseURI_) external onlyOwner {
        baseURI = baseURI_;
    }
    function setMetadataName(string memory metadataName_) external onlyOwner {
        _metadataName = metadataName_;
    }
    function setMetadataDescr(string memory metadataDescr_) external onlyOwner {
        _metadataDescr = metadataDescr_;
    }
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }
    function increaseRank(uint256 tokenID_) external onlyOwner {
        rank[tokenID_]++;
    }
    function decreaseRank(uint256 tokenID_) external onlyOwner {
        rank[tokenID_]--;
    }
    function resetRank(uint256 tokenID_) external onlyOwner {
        rank[tokenID_] = 0;
    }

    function getImage(uint256 tokenId) private view returns (string memory) {
        if (revealed) {
        return string(abi.encodePacked(_baseURI(), Strings.toString(tokenId), '.png?rank=',rank[tokenId]));
        }
        return string(abi.encodePacked(_baseURI(), '0.png'));
    }

    function getMetadata(uint256 tokenId) private view returns (string memory) {
        require(_exists(tokenId), "ERC1155: URI get of nonexistent token");

        string memory attributes = string(abi.encodePacked(
                '[{"trait_type": "', issuedDegrees[tokenId], '", "value": "Received"}]'));
        string memory json = Base64.encode(bytes(string(
                abi.encodePacked('{"name": "', _metadataName,'", "description": "', _metadataDescr,'", "attributes":',
                attributes, ', "image": "', getImage(tokenId),'"}')
            )));

        return json;
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        string memory json = getMetadata(tokenId);
        // non-existent token check integrated
        return string(abi.encodePacked('data:application/json;base64,', json));
    }
}
