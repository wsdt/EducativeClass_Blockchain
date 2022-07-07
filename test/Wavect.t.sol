// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

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
            "https://wavect.io?nft=true", "https://wavect.io/official-nft/wavect_video.mp4", 100, MERKLE_ROOT);
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

    function testNonOwnerDecreaseRank() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavect.decreaseRank(0);
    }

    function testNonOwnerResetRank() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavect.resetRank(0);
    }

    function testOwnerSetMaxWallet() public {
        vm.prank(OWNER);
        wavect.setMaxWallet(1);
        assertEq(wavect.maxWallet(), 1);
    }

    function testOwnerSetBaseURI() public {
        vm.prank(OWNER);
        wavect.setBaseURI("https://wavect.io/official-nft/logo_square.jpg");
        assertEq(wavect.baseURI(), "https://wavect.io/official-nft/logo_square.jpg");
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
        assertEq(wavect.ownerOf(0), NONOWNER);
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
        assertEq(wavect.ownerOf(0), OWNER);
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
        assertEq(wavect.ownerOf(0), OTHER_2);
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
        assertEq(wavect.rank(0), 0);
        wavect.increaseRank(0);
        assertEq(wavect.rank(0), 1);
        wavect.increaseRank(0);
        assertEq(wavect.rank(0), 2);
        vm.stopPrank();
    }

    function testOwnerDecreaseRank() public {
        vm.prank(NONOWNER);
        wavect.mint(NONOWNER_PROOF);
        assertEq(wavect.balanceOf(NONOWNER), 1, "Mint failed");
        vm.startPrank(OWNER);
        assertEq(wavect.rank(0), 0, "Initial rank wrong");
        wavect.increaseRank(0);
        assertEq(wavect.rank(0), 1, "Rank increase failed");

        wavect.decreaseRank(0);
        assertEq(wavect.rank(0), 0, "Decrease failed");
        vm.stopPrank();
    }

    function testOwnerResetRank() public {
        vm.prank(NONOWNER);
        wavect.mint(NONOWNER_PROOF);
        assertEq(wavect.balanceOf(NONOWNER), 1);
        vm.startPrank(OWNER);
        assertEq(wavect.rank(0), 0);
        wavect.increaseRank(0);
        wavect.increaseRank(0);
        assertEq(wavect.rank(0), 2);

        assertEq(wavect.rank(0), 2);
        wavect.resetRank(0);
        assertEq(wavect.rank(0), 0);
        vm.stopPrank();
    }

    function testTotalSupply() public {
        assertEq(wavect.totalSupply(), 100, "Invalid total supply (1)");
        vm.startPrank(OWNER);
        vm.expectRevert("Cannot be smaller");
        wavect.setTotalSupply(2);

        wavect = new Wavect("https://wavect.io/official-nft/contract-metadata.json", "https://wavect.io/official-nft/logo_square.jpg", "Wavect",
            "This NFT can be used to vote on podcast guests, topics and many other things. We also plan to release products in the near future, this NFT will give you then either a lifelong rebate or even allows you to use our products for free.",
            "https://wavect.io?nft=true", "https://wavect.io/official-nft/wavect_video.mp4", 2, MERKLE_ROOT);
        // for custom supply

        assertEq(wavect.totalSupply(), 2, "Invalid total supply (2)");
        wavect.mint(OWNER_PROOF);
        assertEq(wavect.balanceOf(OWNER), 1);
        assertEq(wavect.ownerOf(0), OWNER);
        vm.stopPrank();
        vm.prank(NONOWNER);
        wavect.mint(NONOWNER_PROOF);
        assertEq(wavect.balanceOf(NONOWNER), 1);
        assertEq(wavect.ownerOf(1), NONOWNER);
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
        assertEq(wavect.ownerOf(2), OTHER);

        vm.expectRevert("No more tokens available");
        vm.prank(OTHER_2);
        wavect.mint(OTHER_PROOF_2);
    }

    function testMetadata() public {
        assertEq(wavect.balanceOf(NONOWNER), 0);
        vm.prank(NONOWNER);
        wavect.mint(NONOWNER_PROOF);
        assertEq(wavect.balanceOf(NONOWNER), 1);
        assertEq(wavect.ownerOf(0), NONOWNER);

        string memory onchainMetadata = wavect.tokenURI(0);
        console.log(onchainMetadata);

        vm.prank(OWNER);
        wavect.setReveal(true);
        string memory onchainMetadataRevealed = wavect.tokenURI(0);
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
        wavect.mint(FAULTY_PROOF);
        wavect.setPublicSale(true);
        wavect.mint(FAULTY_PROOF);
        vm.expectRevert("Already minted");
        wavect.mint(FAULTY_PROOF);
        vm.stopPrank();
    }
}
