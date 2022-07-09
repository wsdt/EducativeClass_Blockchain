// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/PullPayment.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "base64-sol/base64.sol";
import "./AddRecover.sol";
import "./LinearlyAssigned.sol";

contract Wavect is ERC721, LinearlyAssigned, AddRecover, ReentrancyGuard, PullPayment, Pausable {

    /// @dev The first 3 tokenIDs are reserved for another use-case (giving incentives to do something good)
    uint256 public constant RESERVED_TOKENS = 3;
    uint256 public constant SOLIDARITY_ID = 0;
    uint256 public constant ENVIRONMENT_ID = 1;
    uint256 public constant HEALTH_ID = 2;

    uint256 public maxWallet;
    uint256 public mintPrice;

    string private _contractURI;
    string public baseURI;
    string public metadataDescr;
    string public metadataName;
    string public metadataExtLink;
    string public metadataAnimationUrl;
    string public imgFileExt;

    bool public revealed;
    bool public publicSaleEnabled;

    bytes32 public merkleRoot;

    /// @dev Used to specifically reward active community members, etc.
    mapping(uint256 => uint256) public communityRank;
    mapping(address => uint256) public minted;
    mapping(uint256 => bool) public usedRewardClaimNonces;

    event RankIncreased(uint256 indexed tokenId, uint256 newRank);
    event RankDecreased(uint256 indexed tokenId, uint256 newRank);
    event RankReset(uint256 indexed tokenId);

    constructor(string memory contractURI_, string memory baseURI_, string memory metadataName_, string memory metadataDescr_,
        string memory metadataExtLink_, string memory metadataAnimationUrl_, string memory imgFileExt_, uint256 totalSupply_,
        bytes32 merkleRoot_)
    ERC721("Wavect", "WACT")
    LinearlyAssigned(totalSupply_, RESERVED_TOKENS)
    {
        maxWallet = 1;
        _contractURI = contractURI_;
        baseURI = baseURI_;
        metadataDescr = metadataDescr_;
        metadataName = metadataName_;
        metadataExtLink = metadataExtLink_;
        metadataAnimationUrl = metadataAnimationUrl_;
        imgFileExt = imgFileExt_;
        merkleRoot = merkleRoot_;
    }

    function prefixed(bytes32 hash) private pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function claimRewardNFT(uint256 tokenID_, uint256 nonce_, bytes memory signature_) external nonReentrant whenNotPaused {
        require(tokenID_ < RESERVED_TOKENS, "Not reward token");
        require(!usedRewardClaimNonces[nonce_], "Nonce used");
        usedRewardClaimNonces[nonce_] = true;

        // recreate client generated message
        bytes32 hash = prefixed(keccak256(abi.encodePacked(_msgSender(), tokenID_, nonce_)));
        require(SignatureChecker.isValidSignatureNow(owner(), hash, signature_), "Invalid voucher"); // only owner signatures

        _mint(_msgSender(), tokenID_);
    }

    function mint(bytes32[] calldata merkleProof_) payable external nonReentrant whenNotPaused {
        require(minted[_msgSender()] < maxWallet, "Already minted");
        require(msg.value >= mintPrice, "Payment too low");

        if (!publicSaleEnabled) {
            bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));
            require(MerkleProof.verify(merkleProof_, merkleRoot, leaf), "Invalid proof");
        }
        _mint(_msgSender(), nextToken());
        minted[_msgSender()] += 1;

        if (msg.value > mintPrice) {
            // if paid too much, allow to get funds back
            _asyncTransfer(_msgSender(), msg.value - mintPrice);
        }
    }

    function withdrawRevenue(address to_) external onlyOwner nonReentrant {
        require(address(this).balance > 0, "No balance");
        payable(to_).transfer(address(this).balance);
    }

    function getImage(uint256 tokenId) private view returns (string memory) {
        if (revealed) {
            return string(abi.encodePacked(_baseURI(), Strings.toString(tokenId), imgFileExt, '?rank=', communityRank[tokenId]));
        }
        return string(abi.encodePacked(_baseURI()));
    }

    function getMetadata(uint256 tokenId) private view returns (string memory) {
        require(_exists(tokenId), "ERC721: URI get of nonexistent token");

        string memory attributes = string(abi.encodePacked(
                '[{"trait_type": "Type", "value": "Super Fan"},{"display_type":"boost_numer","trait_type":"Community Rank","value":',
                Strings.toString(communityRank[tokenId]), '}]'));
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

    function increaseRank(uint256 tokenID_) public onlyOwner {
        require(_exists(tokenID_), "Non existent");
        communityRank[tokenID_] += 1;
        emit RankIncreased(tokenID_, communityRank[tokenID_]);
    }

    function increaseRankBulk(uint256[] calldata tokenIDs_) external onlyOwner {
        for (uint256 i = 0; i < tokenIDs_.length; i++) {
            increaseRank(tokenIDs_[i]);
        }
    }

    function decreaseRank(uint256 tokenID_) public onlyOwner {
        require(_exists(tokenID_), "Non existent");
        communityRank[tokenID_] -= 1;
        emit RankDecreased(tokenID_, communityRank[tokenID_]);
    }

    function decreaseRankBulk(uint256[] calldata tokenIDs_) external onlyOwner {
        for (uint256 i = 0; i < tokenIDs_.length; i++) {
            decreaseRank(tokenIDs_[i]);
        }
    }

    function resetRank(uint256 tokenID_) public onlyOwner {
        require(_exists(tokenID_), "Non existent");
        communityRank[tokenID_] = 0;
        emit RankReset(tokenID_);
    }

    function resetRankBulk(uint256[] calldata tokenIDs_) external onlyOwner {
        for (uint256 i = 0; i < tokenIDs_.length; i++) {
            resetRank(tokenIDs_[i]);
        }
    }

    function setContractURI(string calldata contractURI_) external onlyOwner() {
        _contractURI = contractURI_;
    }

    function setMintPrice(uint256 mintPrice_) external onlyOwner {
        mintPrice = mintPrice_;
    }

    function setImgFileExt(string memory imgFileExt_) external onlyOwner {
        imgFileExt = imgFileExt_;
    }

    function setPublicSale(bool publicSale_) external onlyOwner {
        publicSaleEnabled = publicSale_;
    }

    function setMerkleRoot(bytes32 merkleRoot_) external onlyOwner {
        merkleRoot = merkleRoot_;
    }

    function setPaused(bool pause_) external onlyOwner {
        if (pause_) {
            _pause();
        } else {
            _unpause();
        }
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
