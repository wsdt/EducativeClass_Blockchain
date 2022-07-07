// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "base64-sol/base64.sol";
import "./AddRecover.sol";
import "./LinearlyAssigned.sol";

contract Wavect is ERC721, LinearlyAssigned, AddRecover {

    uint256 public maxWallet;
    uint256 public metadataSellerFeeBps;

    address public metadataFeeRecipient;

    string private _contractURI;
    string public baseURI;
    string public metadataDescr;
    string public metadataName;
    string public metadataExtLink;
    string public metadataAnimationUrl;

    bool public revealed;

    /// @dev Used to specifically reward active community members, etc.
    mapping(uint256 => uint256) public rank;

    constructor(string memory contractURI_, string memory baseURI_, string memory metadataName_, string memory metadataDescr_,
        string memory metadataExtLink_, string memory metadataAnimationUrl_, uint256 totalSupply_)
    ERC721("Wavect", "WACT")
    LinearlyAssigned(totalSupply_, 0)
    {
        maxWallet = 1;
        _contractURI = contractURI_;
        baseURI = baseURI_;
        metadataDescr = metadataDescr_;
        metadataName = metadataName_;
        metadataExtLink = metadataExtLink_;
        metadataAnimationUrl = metadataAnimationUrl_;
    }

    // TODO: Add merkle proof
    function mint() external {
        require(balanceOf(_msgSender()) < maxWallet, "Already minted");
        _mint(_msgSender(), nextToken());
    }

    function getImage(uint256 tokenId) private view returns (string memory) {
        if (revealed) {
            return string(abi.encodePacked(_baseURI(), Strings.toString(tokenId), '.jpg?rank=', rank[tokenId]));
        }
        return string(abi.encodePacked(_baseURI(), 'logo_square.jpg'));
    }

    function getMetadata(uint256 tokenId) private view returns (string memory) {
        require(_exists(tokenId), "ERC1155: URI get of nonexistent token");

        string memory attributes = string(abi.encodePacked(
                '[{"trait_type": "Type", "value": "Super Fan"},{"display_type":"boost_numer","trait_type":"Community Rank","value":',
                rank[tokenId], '}]'));
        string memory json = Base64.encode(bytes(string(
                abi.encodePacked('{"name": "', metadataName, '", "description": "', metadataDescr, '", "attributes":',
                attributes, ', "image": "', getImage(tokenId), '","external_link":"', metadataExtLink,
                '", "youtube_url": "https://www.youtube.com/watch?v=OuIqlNXL3OE", "animation_url": "', metadataAnimationUrl, '"}')
            )));

        return json;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        string memory json = getMetadata(tokenId);
        // non-existent token check integrated
        return string(abi.encodePacked('data:application/json;base64,', json));
    }

    function contractURI() external view returns (string memory) {
        return _contractURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function increaseRank(uint256 tokenID_) external onlyOwner {
        require(_exists(tokenID_), "Non existent");
        rank[tokenID_] += 1;
    }

    function decreaseRank(uint256 tokenID_) external onlyOwner {
        require(_exists(tokenID_), "Non existent");
        rank[tokenID_] -= 1;
    }

    function resetRank(uint256 tokenID_) external onlyOwner {
        require(_exists(tokenID_), "Non existent");
        rank[tokenID_] = 0;
    }

    function setContractURI(string calldata contractURI_) external onlyOwner() {
        _contractURI = contractURI_;
    }

    function setMaxWallet(uint256 maxWallet_) external onlyOwner {
        maxWallet = maxWallet_;
    }

    function setReveal(bool reveal_) external onlyOwner {
        revealed = reveal_;
    }

    /// @dev BaseURI is used for the image itself in this case, since the metadata itself lives on-chain
    function setBaseURI(string memory baseURI_) external onlyOwner {
        baseURI = baseURI_;
    }

    function setMetadataName(string memory metadataName_) external onlyOwner {
        metadataName = metadataName_;
    }

    function setMetadataDescr(string memory metadataDescr_) external onlyOwner {
        metadataDescr = metadataDescr_;
    }

    function setMetadataExtLink(string memory metadataExtLink_) external onlyOwner {
        metadataExtLink = metadataExtLink_;
    }

    function setMetadataAnimationUrl(string memory metadataAnimationUrl_) external onlyOwner {
        metadataAnimationUrl = metadataAnimationUrl_;
    }
}
