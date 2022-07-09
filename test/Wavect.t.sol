// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import "../src/Wavect.sol";
import "forge-std/console2.sol";

contract WavectTest is Test {
    Wavect wavect;
    address constant OWNER = address(1);
    bytes32[] OWNER_PROOF;

    address constant NONOWNER = address(2);
    bytes32[] NONOWNER_PROOF;

    address constant OTHER = address(3);
    bytes32[] OTHER_PROOF;

    address constant OTHER_2 = address(4);
    bytes32[] OTHER_PROOF_2;

    bytes32[] FAULTY_PROOF;

    bytes32 MERKLE_ROOT = 0x5071e19149cc9b870c816e671bc5db717d1d99185c17b082af957a0a93888dd9;

    /// @dev Where do we start, at 0 or do we have reserved tokens?
    uint256 firstTokenID;

    event RankIncreased(uint256 indexed tokenId, uint256 newRank);
    event RankDecreased(uint256 indexed tokenId, uint256 newRank);
    event RankReset(uint256 indexed tokenId);

    function setUp() public {

        OWNER_PROOF.push(0xd52688a8f926c816ca1e079067caba944f158e764817b83fc43594370ca9cf62);
        OWNER_PROOF.push(0x735c77c52a2b69afcd4e13c0a6ece7e4ccdf2b379d39417e21efe8cd10b5ff1b);
        NONOWNER_PROOF.push(0x1468288056310c82aa4c01a7e12a10f8111a0560e72b700555479031b86c357d);
        NONOWNER_PROOF.push(0x735c77c52a2b69afcd4e13c0a6ece7e4ccdf2b379d39417e21efe8cd10b5ff1b);
        OTHER_PROOF.push(0xa876da518a393dbd067dc72abfa08d475ed6447fca96d92ec3f9e7eba503ca61);
        OTHER_PROOF.push(0xf95c14e6953c95195639e8266ab1a6850864d59a829da9f9b13602ee522f672b);
        OTHER_PROOF_2.push(0x5b70e80538acdabd6137353b0f9d8d149f4dba91e8be2e7946e409bfdbe685b9);
        OTHER_PROOF_2.push(0xf95c14e6953c95195639e8266ab1a6850864d59a829da9f9b13602ee522f672b);
        FAULTY_PROOF.push(bytes32(0x00));

        vm.prank(OWNER);
        wavect = new Wavect("https://wavect.io/official-nft/contract-metadata.json", "https://wavect.io/official-nft/logo_square.jpg", "Wavect",
            "This NFT can be used to vote on podcast guests, topics and many other things. We also plan to release products in the near future, this NFT will give you then either a lifelong rebate or even allows you to use our products for free.",
            "https://wavect.io?nft=true", "https://wavect.io/official-nft/wavect_video.mp4", ".jpg", 100, MERKLE_ROOT);

        firstTokenID = wavect.RESERVED_TOKENS();

        vm.stopPrank();
    }

    function testNonOwnerSetContractURI() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavect.setContractURI("..");
    }

    function testNonOwnerSetMaxWallet() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavect.setMaxWallet(1);
    }

    function testNonOwnerSetMintPrice() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavect.setMintPrice(1);
    }

    function testNonOwnerSetImgFileExt() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavect.setImgFileExt(".jpg");
    }

    function testNonOwnerSetBaseURI() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavect.setBaseURI("https://wavect.io/official-nft/logo_square.jpg");
    }

    function testNonOwnerSetReveal() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavect.setReveal(false);
    }

    function testNonOwnerSetMetadataName() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavect.setMetadataName("Wavect");
    }

    function testNonOwnerSetMetadataDescr() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavect.setMetadataDescr("....");
    }

    function testNonOwnerSetPublicSale() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavect.setPublicSale(true);
    }

    function testNonOwnerSetMerkleRoot() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavect.setMerkleRoot("");
    }

    function testNonOwnerSetMetadataExtLink() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavect.setMetadataExtLink("....");
    }

    function testNonOwnerSetMetadataAnimationUrl() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavect.setMetadataAnimationUrl("....");
    }

    function testNonOwnerIncreaseRank() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavect.increaseRank(0);
    }

    function testNonOwnerIncreaseBulkRank() public {
        uint256[] memory ids = new uint256[](2);
        ids[0] = 0;
        ids[1] = 1;
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavect.increaseRankBulk(ids);
    }

    function testNonOwnerDecreaseRank() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavect.decreaseRank(0);
    }

    function testNonOwnerDecreaseBulkRank() public {
        uint256[] memory ids = new uint256[](2);
        ids[0] = 0;
        ids[1] = 1;
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavect.decreaseRankBulk(ids);
    }

    function testNonOwnerResetRank() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavect.resetRank(0);
    }

    function testNonOwnerResetBulkRank() public {
        uint256[] memory ids = new uint256[](2);
        ids[0] = 0;
        ids[1] = 1;
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavect.resetRankBulk(ids);
    }

    function testOwnerSetMaxWallet() public {
        vm.prank(OWNER);
        wavect.setMaxWallet(1);
        assertEq(wavect.maxWallet(), 1);
    }

    function testOwnerSetImgFileExt() public {
        vm.prank(OWNER);
        wavect.setImgFileExt(".jpg");
        assertEq(wavect.imgFileExt(), ".jpg");
    }

    function testOwnerSetBaseURI() public {
        vm.prank(OWNER);
        wavect.setBaseURI("https://wavect.io/official-nft/logo_square.jpg");
        assertEq(wavect.baseURI(), "https://wavect.io/official-nft/logo_square.jpg");
    }

    function testOwnerSetMintPrice() public {
        vm.prank(OWNER);
        wavect.setMintPrice(1);
        assertEq(wavect.mintPrice(), 1);
    }

    function testOwnerSetReveal() public {
        vm.prank(OWNER);
        wavect.setReveal(false);
        assertEq(wavect.revealed(), false);
    }

    function testOwnerSetPublicSale() public {
        vm.prank(OWNER);
        wavect.setPublicSale(true);
        assertEq(wavect.publicSaleEnabled(), true);
    }

    function testOwnerSetMerkleRoot() public {
        vm.prank(OWNER);
        wavect.setMerkleRoot("");
        assertEq(wavect.merkleRoot(), "");
    }

    function testOwnerSetMetadataName() public {
        vm.prank(OWNER);
        wavect.setMetadataName("Wavect");
        assertEq(wavect.metadataName(), "Wavect");
    }

    function testOwnerSetMetadataDescr() public {
        vm.prank(OWNER);
        wavect.setMetadataDescr("This NFT can be used to vote on podcast guests, topics and many other things. We also plan to release products in the near future, this NFT will give you then either a lifelong rebate or even allows you to use our products for free.");
        assertEq(wavect.metadataDescr(), "This NFT can be used to vote on podcast guests, topics and many other things. We also plan to release products in the near future, this NFT will give you then either a lifelong rebate or even allows you to use our products for free.");
    }

    function testOwnerSetMetadataExtLink() public {
        vm.prank(OWNER);
        wavect.setMetadataExtLink("https://wavect.io?nft=true");
        assertEq(wavect.metadataExtLink(), "https://wavect.io?nft=true");
    }

    function testOwnerSetContractURI() public {
        vm.prank(OWNER);
        wavect.setContractURI("https://wavect.io/official-nft/contract-metadata.json");
        assertEq(wavect.contractURI(), "https://wavect.io/official-nft/contract-metadata.json");
    }

    function testOwnerSetMetadataAnimationUrl() public {
        vm.prank(OWNER);
        wavect.setMetadataAnimationUrl("https://wavect.io/official-nft/wavect_video.mp4");
        assertEq(wavect.metadataAnimationUrl(), "https://wavect.io/official-nft/wavect_video.mp4");
    }

    function testOwnerIncreaseRankNonExistent() public {
        vm.expectRevert("Non existent");
        vm.prank(OWNER);
        wavect.increaseRank(0);
    }

    function testOwnerDecreaseRankNonExistent() public {
        vm.expectRevert("Non existent");
        vm.prank(OWNER);
        wavect.decreaseRank(0);
    }

    function testOwnerResetRankNonExistent() public {
        vm.expectRevert("Non existent");
        vm.prank(OWNER);
        wavect.resetRank(0);
    }

    function testNonOwnerMint() public {
        assertEq(wavect.balanceOf(NONOWNER), 0);
        vm.startPrank(NONOWNER);
        wavect.mint(NONOWNER_PROOF);
        assertEq(wavect.balanceOf(NONOWNER), 1);
        assertEq(wavect.ownerOf(firstTokenID), NONOWNER);
        vm.expectRevert("Already minted");
        wavect.mint(NONOWNER_PROOF);
        vm.stopPrank();
        // used startPrank
    }

    function testOwnerMint() public {
        assertEq(wavect.balanceOf(OWNER), 0);
        vm.startPrank(OWNER);
        wavect.mint(OWNER_PROOF);
        assertEq(wavect.balanceOf(OWNER), 1);
        assertEq(wavect.ownerOf(firstTokenID), OWNER);
        vm.expectRevert("Already minted");
        wavect.mint(OWNER_PROOF);
        vm.stopPrank();
        // used startPrank
    }

    function testOther2Mint() public {
        assertEq(wavect.balanceOf(OTHER_2), 0);
        vm.startPrank(OTHER_2);
        wavect.mint(OTHER_PROOF_2);
        assertEq(wavect.balanceOf(OTHER_2), 1);
        assertEq(wavect.ownerOf(firstTokenID), OTHER_2);
        vm.expectRevert("Already minted");
        wavect.mint(OTHER_PROOF_2);
        vm.stopPrank();
        // used startPrank
    }

    function testOwnerIncreaseRank() public {
        vm.prank(NONOWNER);
        wavect.mint(NONOWNER_PROOF);
        assertEq(wavect.balanceOf(NONOWNER), 1);

        vm.startPrank(OWNER);
        assertEq(wavect.communityRank(firstTokenID), 0);
        wavect.increaseRank(firstTokenID);
        assertEq(wavect.communityRank(firstTokenID), 1);

        vm.expectEmit(true, true, false, false);
        emit RankIncreased(firstTokenID, 2);
        wavect.increaseRank(firstTokenID);
        assertEq(wavect.communityRank(firstTokenID), 2);
        vm.stopPrank();
    }

    function testOwnerIncreaseBulkRank() public {
        vm.prank(NONOWNER);
        wavect.mint(NONOWNER_PROOF);
        assertEq(wavect.balanceOf(NONOWNER), 1);
        vm.prank(OTHER);
        wavect.mint(OTHER_PROOF);
        assertEq(wavect.balanceOf(OTHER), 1);

        vm.startPrank(OWNER);
        uint256[] memory ids = new uint256[](2);
        ids[0] = firstTokenID;
        ids[1] = firstTokenID+1;

        assertEq(wavect.communityRank(ids[0]), 0);
        assertEq(wavect.communityRank(ids[1]), 0);
        wavect.increaseRankBulk(ids);
        assertEq(wavect.communityRank(ids[0]), 1);
        assertEq(wavect.communityRank(ids[1]), 1);
        vm.stopPrank();
    }

    function testOwnerDecreaseBulkRank() public {
        vm.prank(NONOWNER);
        wavect.mint(NONOWNER_PROOF);
        assertEq(wavect.balanceOf(NONOWNER), 1);
        vm.prank(OTHER);
        wavect.mint(OTHER_PROOF);
        assertEq(wavect.balanceOf(OTHER), 1);

        vm.startPrank(OWNER);
        uint256[] memory ids = new uint256[](2);
        ids[0] = firstTokenID;
        ids[1] = firstTokenID+1;

        assertEq(wavect.communityRank(ids[0]), 0);
        assertEq(wavect.communityRank(ids[1]), 0);


        // decreasing below 0 fails by default in new solidity versions.

        wavect.increaseRankBulk(ids);
        assertEq(wavect.communityRank(ids[0]), 1);
        assertEq(wavect.communityRank(ids[1]), 1);

        wavect.decreaseRankBulk(ids);

        assertEq(wavect.communityRank(ids[0]), 0);
        assertEq(wavect.communityRank(ids[1]), 0);
        vm.stopPrank();
    }

    function testOwnerDecreaseRank() public {
        vm.prank(NONOWNER);
        wavect.mint(NONOWNER_PROOF);
        assertEq(wavect.balanceOf(NONOWNER), 1, "Mint failed");
        vm.startPrank(OWNER);
        assertEq(wavect.communityRank(firstTokenID), 0, "Initial rank wrong");
        wavect.increaseRank(firstTokenID);
        assertEq(wavect.communityRank(firstTokenID), 1, "Rank increase failed");

        vm.expectEmit(true, true, false, false);
        emit RankDecreased(firstTokenID, 1);
        wavect.decreaseRank(firstTokenID);
        assertEq(wavect.communityRank(firstTokenID), 0, "Decrease failed");
        vm.stopPrank();
    }

    function testOwnerResetRank() public {
        vm.prank(NONOWNER);
        wavect.mint(NONOWNER_PROOF);
        assertEq(wavect.balanceOf(NONOWNER), 1);
        vm.startPrank(OWNER);
        assertEq(wavect.communityRank(firstTokenID), 0);
        wavect.increaseRank(firstTokenID);
        wavect.increaseRank(firstTokenID);
        assertEq(wavect.communityRank(firstTokenID), 2);

        vm.expectEmit(true, false, false, false);
        emit RankReset(firstTokenID);
        wavect.resetRank(firstTokenID);
        assertEq(wavect.communityRank(firstTokenID), 0);
        vm.stopPrank();
    }

    function testOwnerResetBulkRank() public {
        vm.prank(NONOWNER);
        wavect.mint(NONOWNER_PROOF);
        assertEq(wavect.balanceOf(NONOWNER), 1);
        vm.prank(OTHER);
        wavect.mint(OTHER_PROOF);
        assertEq(wavect.balanceOf(OTHER), 1);

        vm.startPrank(OWNER);
        uint256[] memory ids = new uint256[](2);
        ids[0] = firstTokenID;
        ids[1] = firstTokenID+1;

        assertEq(wavect.communityRank(ids[0]), 0);
        assertEq(wavect.communityRank(ids[1]), 0);

        wavect.increaseRankBulk(ids);
        wavect.increaseRankBulk(ids);
        assertEq(wavect.communityRank(ids[0]), 2);
        assertEq(wavect.communityRank(ids[1]), 2);

        wavect.resetRankBulk(ids);

        assertEq(wavect.communityRank(ids[0]), 0);
        assertEq(wavect.communityRank(ids[1]), 0);
        vm.stopPrank();
    }

    function testTotalSupply() public {
        assertEq(wavect.totalSupply(), 100, "Invalid total supply (1)");
        vm.startPrank(OWNER);
        vm.expectRevert("Cannot be smaller");
        wavect.setTotalSupply(2);

        wavect = new Wavect("https://wavect.io/official-nft/contract-metadata.json", "https://wavect.io/official-nft/logo_square.jpg", "Wavect",
            "This NFT can be used to vote on podcast guests, topics and many other things. We also plan to release products in the near future, this NFT will give you then either a lifelong rebate or even allows you to use our products for free.",
            "https://wavect.io?nft=true", "https://wavect.io/official-nft/wavect_video.mp4", ".jpg", 2, MERKLE_ROOT);
        // for custom supply

        assertEq(wavect.totalSupply(), 2, "Invalid total supply (2)");
        wavect.mint(OWNER_PROOF);
        assertEq(wavect.balanceOf(OWNER), 1);
        assertEq(wavect.ownerOf(firstTokenID), OWNER);
        vm.stopPrank();
        vm.prank(NONOWNER);
        wavect.mint(NONOWNER_PROOF);
        assertEq(wavect.balanceOf(NONOWNER), 1);
        assertEq(wavect.ownerOf(firstTokenID+1), NONOWNER);
        vm.expectRevert("No more tokens available");
        vm.prank(OTHER);
        wavect.mint(OTHER_PROOF);
        assertEq(wavect.balanceOf(OTHER), 0);

        vm.startPrank(OWNER);
        wavect.setTotalSupply(3);
        wavect.freezeTotalSupply();
        vm.expectRevert("Supply frozen");
        wavect.setTotalSupply(100);
        vm.stopPrank();

        vm.prank(OTHER);
        wavect.mint(OTHER_PROOF);
        assertEq(wavect.balanceOf(OTHER), 1);
        assertEq(wavect.ownerOf(firstTokenID+2), OTHER);

        vm.expectRevert("No more tokens available");
        vm.prank(OTHER_2);
        wavect.mint(OTHER_PROOF_2);
    }

    function testMetadata() public {
        assertEq(wavect.balanceOf(NONOWNER), 0);
        vm.prank(NONOWNER);
        wavect.mint(NONOWNER_PROOF);
        assertEq(wavect.balanceOf(NONOWNER), 1);
        assertEq(wavect.ownerOf(firstTokenID), NONOWNER);

        string memory onchainMetadata = wavect.tokenURI(firstTokenID);
        console.log(onchainMetadata);

        vm.prank(OWNER);
        wavect.setReveal(true);
        string memory onchainMetadataRevealed = wavect.tokenURI(firstTokenID);
        assert(keccak256(abi.encodePacked(onchainMetadata)) != keccak256(abi.encodePacked(onchainMetadataRevealed)));
        // must be different
    }

    function testWhitelist() public {
        assertEq(wavect.balanceOf(OTHER_2), 0);
        vm.prank(OTHER_2);
        wavect.mint(OTHER_PROOF_2);
        assertEq(wavect.balanceOf(OTHER_2), 1);

        vm.startPrank(OWNER);
        vm.expectRevert("Invalid proof");
        wavect.mint(NONOWNER_PROOF);
        vm.expectRevert("Invalid proof");
        wavect.mint(FAULTY_PROOF);
        wavect.setPublicSale(true);
        wavect.mint(FAULTY_PROOF);
        vm.expectRevert("Already minted");
        wavect.mint(FAULTY_PROOF);
        wavect.safeTransferFrom(OWNER, NONOWNER, firstTokenID+1);
        vm.expectRevert("Already minted");
        wavect.mint(FAULTY_PROOF);
        vm.stopPrank();
    }

    function testPrice() public {
        assertEq(wavect.balanceOf(OTHER_2), 0);
        vm.prank(OTHER_2);
        wavect.mint(OTHER_PROOF_2);
        // for free
        assertEq(wavect.balanceOf(OTHER_2), 1);

        vm.startPrank(OWNER);
        wavect.setMintPrice(0.1 ether);
        assertEq(wavect.balanceOf(OWNER), 0);
        vm.expectRevert("Payment too low");
        wavect.mint(OWNER_PROOF);

        vm.deal(OWNER, 0.1 ether);
        wavect.mint{value : 0.1 ether}(OWNER_PROOF);
        assertEq(wavect.balanceOf(OWNER), 1);

        assertEq(address(wavect).balance, 0.1 ether);
        wavect.withdrawRevenue(NONOWNER);
        assertEq(address(NONOWNER).balance, 0.1 ether);
        assertEq(address(wavect).balance, 0 ether);

        vm.expectRevert("No balance");
        wavect.withdrawRevenue(NONOWNER);
        vm.stopPrank();

        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavect.withdrawRevenue(OWNER);
    }

    function testPullPayment() public {
        vm.prank(OWNER);
        wavect.setMintPrice(0.1 ether);
        assertEq(wavect.balanceOf(OWNER), 0);

        vm.deal(NONOWNER, 1 ether);
        vm.prank(NONOWNER);
        wavect.mint{value : 1 ether}(NONOWNER_PROOF);
        assertEq(wavect.balanceOf(NONOWNER), 1);
        assertEq(address(NONOWNER).balance, 0 ether);

        vm.prank(OTHER_2);
        wavect.withdrawPayments(payable(OTHER_2));
        assertEq(address(OTHER_2).balance, 0 ether);

        vm.prank(NONOWNER);
        wavect.withdrawPayments(payable(NONOWNER));
        assertEq(address(NONOWNER).balance, 0.9 ether);
        assertEq(address(wavect).balance, 0.1 ether);

        vm.prank(OWNER);
        wavect.withdrawRevenue(OTHER);
        assertEq(address(OTHER).balance, 0.1 ether);
        assertEq(address(wavect).balance, 0 ether);

        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavect.withdrawRevenue(OWNER);
    }

    function testPausable() public {
        assertEq(wavect.balanceOf(NONOWNER), 0);
        vm.startPrank(NONOWNER);
        wavect.mint(NONOWNER_PROOF);
        assertEq(wavect.balanceOf(NONOWNER), 1);
        assertEq(wavect.ownerOf(firstTokenID), NONOWNER);
        vm.stopPrank();

        vm.prank(OWNER);
        wavect.setPaused(true);
        assertEq(wavect.balanceOf(OWNER), 0);
        vm.expectRevert("Pausable: paused");
        wavect.mint(OWNER_PROOF);
    }

    function testImproveTokens() public {
        assertEq(wavect.RESERVED_TOKENS(), 3, "Unexpected amount of reserved tokens");
    }

    event Received(uint);

    receive() external payable {
        emit Received(msg.value);
    }
}
