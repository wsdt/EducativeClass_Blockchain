// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import "../src/Wavect.sol";
import "forge-std/console2.sol";

contract WavectTest is Test {
    Wavect wavect;
    address constant OWNER = address(0x14791697260E4c9A71f18484C9f997B308e59325);
    bytes32[] OWNER_PROOF;
    bytes OWNER_SIG_EXAMPLE = hex"2a10fa3403560e476d7f93eebcfb24fb70b39c00407fae4a45f76d9233cff9cf5d1403b69de1ab688c9d78fd4394cb883c343269384d68468dbbe2c8bfaee2091c";
    bytes FAULTY_SIG_EXAMPLE = hex"2a10fa3403560e476d7f93eebcfb24fb70b39c00407fae4a45f76d9233cff9cf5d1403b69de1ab688c9d78fd4394cb883c343269384d68468dbbe2c8bfaee2091d";

    address constant NONOWNER = address(1); // NOTE: the 0x01 address does not work always
    bytes32[] NONOWNER_PROOF;

    address constant OTHER = address(2);
    bytes32[] OTHER_PROOF;

    address constant OTHER_2 = address(3);
    bytes32[] OTHER_PROOF_2;

    bytes32[] FAULTY_PROOF;

    bytes32 MERKLE_ROOT = 0x289eb88ae6a8930e137c767ec946fc9d80a02f04a32104b62a67cd6aad816d30;

    address constant L0_ENDPOINT = address(42);

    /// @dev Where do we start, at 0 or do we have reserved tokens?
    uint256 firstTokenID;

    event RankIncreased(uint256 indexed tokenId, uint256 newRank);
    event RankDecreased(uint256 indexed tokenId, uint256 newRank);
    event RankReset(uint256 indexed tokenId);

    function setUp() public {

        OWNER_PROOF.push(0x1468288056310c82aa4c01a7e12a10f8111a0560e72b700555479031b86c357d);
        OWNER_PROOF.push(0x32ce85405983c392122c7c4869690b8081fc9ecec74276206caea196c6e545cb);
        NONOWNER_PROOF.push(0x513741ffb1226167f112de55d110bf11ff18ebc0afe0068c899d583a66d755c8);
        NONOWNER_PROOF.push(0x32ce85405983c392122c7c4869690b8081fc9ecec74276206caea196c6e545cb);
        OTHER_PROOF.push(0x5b70e80538acdabd6137353b0f9d8d149f4dba91e8be2e7946e409bfdbe685b9);
        OTHER_PROOF.push(0x0827f224e08cb622b4f65d2795452706e60cc2aaa0b8cd8143170f563b35e581);
        OTHER_PROOF_2.push(0xd52688a8f926c816ca1e079067caba944f158e764817b83fc43594370ca9cf62);
        OTHER_PROOF_2.push(0x0827f224e08cb622b4f65d2795452706e60cc2aaa0b8cd8143170f563b35e581);
        FAULTY_PROOF.push(bytes32(0x00));

        vm.prank(OWNER);
        wavect = new Wavect(L0_ENDPOINT, "https://wavect.io/official-nft/contract-metadata.json", "https://wavect.io/official-nft/metadata/1.json?debug=",
            "Wavect", "WACT", ".json", 100, MERKLE_ROOT);

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

    function testNonOwnerSetFileExt() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavect.setFileExt(".json");
    }

    function testNonOwnerSetBaseURI() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavect.setBaseURI("https://wavect.io/official-nft/metadata/");
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

    function testOwnerSetFileExt() public {
        vm.prank(OWNER);
        wavect.setFileExt(".json");
        assertEq(wavect.fileExt(), ".json");
    }

    function testOwnerSetBaseURI() public {
        vm.prank(OWNER);
        wavect.setBaseURI("https://wavect.io/official-nft/metadata/");
        assertEq(wavect.baseURI(), "https://wavect.io/official-nft/metadata/");
    }

    function testOwnerSetMintPrice() public {
        vm.prank(OWNER);
        wavect.setMintPrice(1);
        assertEq(wavect.mintPrice(), 1);
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

    function testOwnerSetContractURI() public {
        vm.prank(OWNER);
        wavect.setContractURI("https://wavect.io/official-nft/contract-metadata.json");
        assertEq(wavect.contractURI(), "https://wavect.io/official-nft/contract-metadata.json");
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

    function testTotalSupply() public {
        assertEq(wavect.totalSupply(), 100, "Invalid total supply (1)");
        vm.startPrank(OWNER);
        vm.expectRevert("Cannot be smaller");
        wavect.setTotalSupply(2);

        wavect = new Wavect(L0_ENDPOINT, "https://wavect.io/official-nft/contract-metadata.json", "https://wavect.io/official-nft/metadata/1.json?debug=",
            "Wavect", "WACT", ".json", 2, MERKLE_ROOT);
        // for custom supply

        assertEq(wavect.totalSupply(), 2, "Invalid total supply (2)");
        wavect.mint(OWNER_PROOF);
        assertEq(wavect.balanceOf(OWNER), 1);
        assertEq(wavect.ownerOf(firstTokenID), OWNER);
        vm.stopPrank();
        vm.prank(NONOWNER);
        wavect.mint(NONOWNER_PROOF);
        assertEq(wavect.balanceOf(NONOWNER), 1);
        assertEq(wavect.ownerOf(firstTokenID + 1), NONOWNER);
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
        assertEq(wavect.ownerOf(firstTokenID + 2), OTHER);

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

        assertEq(wavect.fileExt(), ".json");
        vm.prank(OWNER);
        wavect.setFileExt("");
        assertEq(wavect.fileExt(), "");

        string memory onchainMetadataFileExt = wavect.tokenURI(firstTokenID);
        assert(keccak256(abi.encodePacked(onchainMetadata)) != keccak256(abi.encodePacked(onchainMetadataFileExt)));
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
        wavect.safeTransferFrom(OWNER, NONOWNER, firstTokenID + 1);
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
        wavect.withdrawRevenue(OTHER);
        assertEq(address(OTHER).balance, 0.1 ether);
        assertEq(address(wavect).balance, 0 ether);

        vm.expectRevert("No balance");
        wavect.withdrawRevenue(OTHER);
        vm.stopPrank();

        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(OTHER);
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

        vm.expectRevert("Pausable: paused");
        wavect.claimRewardNFT(firstTokenID, 0, "");
    }

    function testImproveTokens() public {
        assertEq(wavect.RESERVED_TOKENS(), 3, "Unexpected amount of reserved tokens");
        assertEq(wavect.SOLIDARITY_ID(), 0, "Unexpected Solidarity ID");
        assertEq(wavect.ENVIRONMENT_ID(), 1, "Unexpected Environment ID");
        assertEq(wavect.HEALTH_ID(), 2, "Unexpected Health ID");

        vm.startPrank(NONOWNER);
        wavect.mint(NONOWNER_PROOF);
        assertEq(wavect.balanceOf(NONOWNER), 1);
        assertEq(wavect.ownerOf(firstTokenID), NONOWNER);
        assertEq(firstTokenID, 3);

        assertEq(wavect.usedRewardClaimNonces(0), false, "Nonce already used");
        vm.stopPrank();

        vm.expectRevert("Invalid voucher");
        vm.prank(OTHER);
        wavect.claimRewardNFT(0, 0, OWNER_SIG_EXAMPLE);
        assertEq(wavect.usedRewardClaimNonces(0), false, "Nonce already used");

        vm.expectRevert("Invalid voucher");
        vm.prank(OTHER_2);
        wavect.claimRewardNFT(0, 0, FAULTY_SIG_EXAMPLE);
        assertEq(wavect.usedRewardClaimNonces(0), false, "Nonce already used");

        console.log(string(abi.encodePacked()));
        vm.prank(OTHER_2);
        wavect.claimRewardNFT(0, 0, OWNER_SIG_EXAMPLE);
        assertEq(wavect.usedRewardClaimNonces(0), true, "Nonce not used");
        assertEq(wavect.balanceOf(OTHER_2), 1);
        assertEq(wavect.ownerOf(0), OTHER_2);

        vm.expectRevert("Nonce used");
        vm.prank(OTHER_2);
        wavect.claimRewardNFT(0, 0, OWNER_SIG_EXAMPLE);

        vm.expectRevert("Not reward token");
        vm.prank(OTHER_2);
        wavect.claimRewardNFT(firstTokenID, 0, OWNER_SIG_EXAMPLE);

        assertEq(wavect.usedRewardClaimNonces(1), false, "Nonce already used");
        vm.expectRevert("Invalid voucher");
        vm.prank(OTHER_2);
        wavect.claimRewardNFT(0, 1, OWNER_SIG_EXAMPLE);


        string memory onchainMetadata = wavect.tokenURI(firstTokenID);
        console.log(onchainMetadata);

        string memory onchainMetadataSpecial = wavect.tokenURI(0);
        console.log(onchainMetadataSpecial);

        assert(keccak256(abi.encodePacked(onchainMetadata)) != keccak256(abi.encodePacked(onchainMetadataSpecial)));
        // useful since non-revealed metadata is identical for regular tokens
        // must be different


    }

    function testIsApprovedAll() public {
        address OS_1 = address(0x58807baD0B376efc12F5AD86aAc70E78ed67deaE);
        address OS_2 = address(0xff7Ca10aF37178BdD056628eF42fD7F799fAc77c);

        vm.startPrank(NONOWNER);
        assertEq(wavect.isApprovedForAll(NONOWNER, OWNER), false, "Should not be approved (1)");
        wavect.setApprovalForAll(OWNER, true);
        assertEq(wavect.isApprovedForAll(NONOWNER, OWNER), true, "Should be approved (1)");
        wavect.setApprovalForAll(OWNER, false);
        assertEq(wavect.isApprovedForAll(NONOWNER, OWNER), false, "Should not be approved (2)");

        assertEq(wavect.isApprovedForAll(NONOWNER, OS_1), true, "OS should be approved (1)");
        assertEq(wavect.isApprovedForAll(NONOWNER, OS_2), true, "OS should be approved (2)");
        wavect.setApprovalForAll(OS_1, false);
        wavect.setApprovalForAll(OS_2, false);
        assertEq(wavect.isApprovedForAll(NONOWNER, OS_1), true, "OS should be approved (3)");
        assertEq(wavect.isApprovedForAll(NONOWNER, OS_2), true, "OS should be approved (4)");
        vm.stopPrank();
    }

    event Received(uint);

    receive() external payable {
        emit Received(msg.value);
    }
}
