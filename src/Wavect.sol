// SPDX-License-Identifier: UNLICENSED
/*
* This code must not be forked, replicated, modified or used by any other entity or person without explicit approval of Wavect GmbH.
* Website: https://wavect.io
* E-Mail: office@wavect.io
*/
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/security/PullPayment.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./AddRecover.sol";
import "./LinearlyAssigned.sol";
import "@layer-zero/contracts/token/onft/IONFT721.sol";
import "@layer-zero/contracts/token/onft/ONFT721Core.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";

contract Wavect is ERC721, LinearlyAssigned, AddRecover, PullPayment, Pausable, ONFT721Core, IONFT721, Multicall, ReentrancyGuard {

    /// @dev The first 3 tokenIDs are reserved for another use-case (giving incentives to do something good)
    uint256 public constant RESERVED_TOKENS = 3;
    uint256 public constant SOLIDARITY_ID = 0;
    uint256 public constant ENVIRONMENT_ID = 1;
    uint256 public constant HEALTH_ID = 2;

    uint256 public maxWallet;
    uint256 public mintPrice;

    string private _contractURI;
    string public baseURI;
    string public fileExt;

    bool public publicSaleEnabled;

    bytes32 public merkleRoot;

    /// @dev Used to specifically reward active community members, etc.
    mapping(uint256 => uint256) public communityRank;
    mapping(address => uint256) public minted;
    mapping(uint256 => bool) public usedRewardClaimNonces;

    event RankIncreased(uint256 indexed tokenId, uint256 newRank);
    event RankDecreased(uint256 indexed tokenId, uint256 newRank);
    event RankReset(uint256 indexed tokenId);

    constructor(address _lzEndpoint, string memory contractURI_, string memory baseURI_, string memory name_,
        string memory ticker_, string memory fileExt_, uint256 totalSupply_, bytes32 merkleRoot_, bool mintEnabled_)
    ONFT721Core(_lzEndpoint)
    ERC721(name_, ticker_)
    LinearlyAssigned(totalSupply_, RESERVED_TOKENS)
    {
        maxWallet = 1;
        _contractURI = contractURI_;
        baseURI = baseURI_;
        fileExt = fileExt_;
        merkleRoot = merkleRoot_;

        /* Important to ensure that NFT only exists on one chain (for regular NFTs)
        * and for the reward nfts to ensure that nonces/signatures cannot be reused. */
        if (!mintEnabled_) {
            _pause();
        }
    }

    function claimRewardNFT(uint256 tokenID_, uint256 nonce_, bytes memory signature_) external whenNotPaused nonReentrant {
        require(tokenID_ < RESERVED_TOKENS, "Not reward token");
        require(!usedRewardClaimNonces[nonce_], "Nonce used");
        usedRewardClaimNonces[nonce_] = true;

        // recreate client generated message
        bytes32 hash = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(_msgSender(), tokenID_, nonce_)));
        require(SignatureChecker.isValidSignatureNow(owner(), hash, signature_), "Invalid voucher");
        // only owner signatures

        _mint(_msgSender(), tokenID_);
    }

    function mint(bytes32[] calldata merkleProof_) payable external whenNotPaused nonReentrant {
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
        _asyncTransfer(owner(), payments(owner()) + mintPrice); // for claiming revenue
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireMinted(tokenId);
        return string(abi.encodePacked(baseURI, Strings.toString(tokenId), fileExt));
    }

    function contractURI() external view returns (string memory) {
        return _contractURI;
    }

    function setFileExt(string memory fileExt_) external onlyOwner {
        fileExt = fileExt_;
    }

    function increaseRank(uint256 tokenID_) public onlyOwner {
        require(_exists(tokenID_), "Non existent");
        communityRank[tokenID_] += 1;
        emit RankIncreased(tokenID_, communityRank[tokenID_]);
    }

    function decreaseRank(uint256 tokenID_) public onlyOwner {
        require(_exists(tokenID_), "Non existent");
        communityRank[tokenID_] -= 1;
        emit RankDecreased(tokenID_, communityRank[tokenID_]);
    }

    function resetRank(uint256 tokenID_) public onlyOwner {
        require(_exists(tokenID_), "Non existent");
        communityRank[tokenID_] = 0;
        emit RankReset(tokenID_);
    }

    function setContractURI(string calldata contractURI_) external onlyOwner() {
        _contractURI = contractURI_;
    }

    function setBaseURI(string calldata baseURI_) external onlyOwner() {
        baseURI = baseURI_;
    }

    function setMintPrice(uint256 mintPrice_) external onlyOwner {
        mintPrice = mintPrice_;
    }

    function setPublicSale(bool publicSale_) external onlyOwner {
        publicSaleEnabled = publicSale_;
    }

    function setMerkleRoot(bytes32 merkleRoot_) external onlyOwner {
        merkleRoot = merkleRoot_;
    }

    /* @dev Important to ensure that NFT only exists on one chain (for regular NFTs)
        * and for the reward nfts to ensure that nonces/signatures cannot be reused. */
    function setDisableMint(bool pause_) external onlyOwner {
        if (pause_) {
            _pause();
        } else {
            _unpause();
        }
    }

    function setMaxWallet(uint256 maxWallet_) external onlyOwner {
        maxWallet = maxWallet_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ONFT721Core, ERC721, IERC165) returns (bool) {
        return interfaceId == type(IONFT721).interfaceId || super.supportsInterface(interfaceId);
    }

    function _debitFrom(address _from, uint16, bytes memory, uint _tokenId) internal virtual override {
        require(_isApprovedOrOwner(_msgSender(), _tokenId), "ONFT721: send caller is not owner nor approved");
        require(ERC721.ownerOf(_tokenId) == _from, "ONFT721: send from incorrect owner");
        _burn(_tokenId);
    }

    function _creditTo(uint16, address _toAddress, uint _tokenId) internal virtual override {
        _safeMint(_toAddress, _tokenId);
    }
}
