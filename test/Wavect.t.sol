// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import "../src/Wavect.sol";
import "forge-std/console2.sol";
import "@layer-zero/contracts/mocks/LZEndpointMock.sol";

contract WavectTest is Test {
    Wavect wavectA;
    Wavect wavectB;
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

    uint16 constant LOCAL_CHAIN_ID = 31337;
    address constant L0_ENDPOINT_DUMMY = address(42);
    LZEndpointMock L0EndpointChainA;
    LZEndpointMock L0EndpointChainB;

    /// @dev Where do we start, at 0 or do we have reserved tokens?
    uint256 firstTokenID;

    event RankIncreased(uint256 indexed tokenId, uint256 newRank);
    event RankDecreased(uint256 indexed tokenId, uint256 newRank);
    event RankReset(uint256 indexed tokenId);
    event SendToChain(address _from, uint16 _dstChainId, address _toAddress, uint256 _tokenId, uint256 nonce);

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

        vm.startPrank(OWNER);
        L0EndpointChainA = new LZEndpointMock(LOCAL_CHAIN_ID);
        L0EndpointChainB = new LZEndpointMock(LOCAL_CHAIN_ID);

        wavectA = new Wavect(address(L0EndpointChainA), "https://wavect.io/official-nft/contract-metadata.json", "https://wavect.io/official-nft/metadata/1.json?debug=",
            "Wavect", "WACT", ".json", 100, MERKLE_ROOT, false);
        wavectB = new Wavect(address(L0EndpointChainB), "https://wavect.io/official-nft/contract-metadata.json", "https://wavect.io/official-nft/metadata/1.json?debug=",
            "Wavect", "WACT", ".json", 100, MERKLE_ROOT, true);

        L0EndpointChainA.setDestLzEndpoint(address(wavectB), address(L0EndpointChainB));
        L0EndpointChainB.setDestLzEndpoint(address(wavectA), address(L0EndpointChainA));

        wavectA.setTrustedRemote(LOCAL_CHAIN_ID, abi.encodePacked(address(wavectB)));
        wavectB.setTrustedRemote(LOCAL_CHAIN_ID, abi.encodePacked(address(wavectA)));
        vm.stopPrank();

        //uint16 chainID = uint16(wavect.getChainId());
        //console.log(chainID);

        firstTokenID = wavectA.RESERVED_TOKENS();

        vm.stopPrank();
    }

    function testLayerZeroBridging() public {
        uint256 expectedTokenID = 3;

        vm.prank(NONOWNER);
        wavectA.mint(NONOWNER_PROOF);
        assertEq(wavectA.balanceOf(NONOWNER), 1, "Could not mint");
        wavectA.tokenURI(expectedTokenID);
        // does not fail

        vm.expectRevert("ERC721: invalid token ID");
        wavectB.tokenURI(expectedTokenID);

        vm.prank(NONOWNER);
        wavectA.transferFrom(NONOWNER, OTHER, expectedTokenID);
        assertEq(wavectA.balanceOf(NONOWNER), 0, "Could not transfer (1)");
        assertEq(wavectA.balanceOf(OTHER), 1, "Could not transfer (2)");

        vm.startPrank(OTHER);
        wavectA.approve(address(wavectA), expectedTokenID);

        wavectA.sendFrom(
            OTHER,
            LOCAL_CHAIN_ID,
            abi.encodePacked(OTHER),
            expectedTokenID,
            payable(OTHER),
            address(0),
            ""
        );

        assertEq(wavectA.balanceOf(OTHER), 0, "Could not burn (1)");
        assertEq(wavectB.balanceOf(OTHER), 1, "Could not bridge (1)");

        vm.expectRevert("ERC721: invalid token ID");
        wavectA.tokenURI(expectedTokenID);
        wavectB.tokenURI(expectedTokenID);
        // should not fail anymore

        assertEq(wavectB.communityRank(expectedTokenID), 0, "Wrong rank (1)");
        vm.stopPrank();
        vm.prank(OWNER);
        wavectB.increaseRank(expectedTokenID);
        assertEq(wavectB.communityRank(expectedTokenID), 1, "Wrong rank (2)");

        // test if newly minted tokenIDs are right
        vm.prank(OTHER_2);
        wavectA.mint(OTHER_PROOF_2);
        assertEq(wavectA.balanceOf(OTHER_2), 1, "Could not mint (2)");
        wavectA.tokenURI(expectedTokenID + 1);


        vm.startPrank(OTHER);
        wavectB.approve(address(wavectB), expectedTokenID);

        wavectB.sendFrom(
            OTHER,
            LOCAL_CHAIN_ID,
            abi.encodePacked(OTHER),
            expectedTokenID,
            payable(OTHER),
            address(0),
            ""
        );

        assertEq(wavectB.balanceOf(OTHER), 0, "Could not burn (2)");
        assertEq(wavectA.balanceOf(OTHER), 1, "Could not bridge (2)");
        assertEq(wavectA.communityRank(expectedTokenID), 1, "Wrong rank (3)");
        assertEq(wavectB.communityRank(expectedTokenID), 0, "Wrong rank (4)");
        vm.stopPrank();
    }

    function testNonOwnerSetContractURI() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavectA.setContractURI("..");
    }

    function testNonOwnerSetMaxWallet() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavectA.setMaxWallet(1);
    }

    function testNonOwnerSetMintPrice() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavectA.setMintPrice(1);
    }

    function testNonOwnerSetMintEnabled() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavectA.setDisableMint(false);
    }

    function testNonOwnerSetFileExt() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavectA.setFileExt(".json");
    }

    function testNonOwnerSetBaseURI() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavectA.setBaseURI("https://wavect.io/official-nft/metadata/");
    }

    function testNonOwnerSetPublicSale() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavectA.setPublicSale(true);
    }

    function testNonOwnerSetMerkleRoot() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavectA.setMerkleRoot("");
    }

    function testMulticall() public {
        vm.startPrank(OWNER);
        bytes[] memory payload = new bytes[](2);
        payload[0] = abi.encodeWithSelector(wavectA.mint.selector, OWNER_PROOF);
        payload[1] = abi.encodeWithSelector(wavectA.increaseRank.selector, 3);
        wavectA.multicall(payload);
        vm.stopPrank();
    }

    function testNonOwnerIncreaseRank() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavectA.increaseRank(0);
    }

    function testNonOwnerDecreaseRank() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavectA.decreaseRank(0);
    }

    function testNonOwnerResetRank() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(NONOWNER);
        wavectA.resetRank(0);
    }

    function testOwnerSetMaxWallet() public {
        vm.prank(OWNER);
        wavectA.setMaxWallet(1);
        assertEq(wavectA.maxWallet(), 1);
    }

    function testOwnerSetFileExt() public {
        vm.prank(OWNER);
        wavectA.setFileExt(".json");
        assertEq(wavectA.fileExt(), ".json");
    }

    function testOwnerSetBaseURI() public {
        vm.prank(OWNER);
        wavectA.setBaseURI("https://wavect.io/official-nft/metadata/");
        assertEq(wavectA.baseURI(), "https://wavect.io/official-nft/metadata/");
    }

    function testOwnerSetMintPrice() public {
        vm.prank(OWNER);
        wavectA.setMintPrice(1);
        assertEq(wavectA.mintPrice(), 1);
    }

    function testOwnerSetDisableMint() public {
        assertEq(wavectA.paused(), false);
        vm.prank(OWNER);
        wavectA.setDisableMint(true);
        assertEq(wavectA.paused(), true);
    }

    function testOwnerSetPublicSale() public {
        vm.prank(OWNER);
        wavectA.setPublicSale(true);
        assertEq(wavectA.publicSaleEnabled(), true);
    }

    function testOwnerSetMerkleRoot() public {
        vm.prank(OWNER);
        wavectA.setMerkleRoot("");
        assertEq(wavectA.merkleRoot(), "");
    }

    function testOwnerSetContractURI() public {
        vm.prank(OWNER);
        wavectA.setContractURI("https://wavect.io/official-nft/contract-metadata.json");
        assertEq(wavectA.contractURI(), "https://wavect.io/official-nft/contract-metadata.json");
    }

    function testOwnerIncreaseRankNonExistent() public {
        vm.expectRevert("Non existent");
        vm.prank(OWNER);
        wavectA.increaseRank(0);
    }

    function testOwnerDecreaseRankNonExistent() public {
        vm.expectRevert("Non existent");
        vm.prank(OWNER);
        wavectA.decreaseRank(0);
    }

    function testOwnerResetRankNonExistent() public {
        vm.expectRevert("Non existent");
        vm.prank(OWNER);
        wavectA.resetRank(0);
    }

    function testNonOwnerMint() public {
        assertEq(wavectA.balanceOf(NONOWNER), 0);
        vm.startPrank(NONOWNER);
        wavectA.mint(NONOWNER_PROOF);
        assertEq(wavectA.balanceOf(NONOWNER), 1);
        assertEq(wavectA.ownerOf(firstTokenID), NONOWNER);
        vm.expectRevert("Already minted");
        wavectA.mint(NONOWNER_PROOF);
        vm.stopPrank();
        // used startPrank
    }

    function testOwnerMint() public {
        assertEq(wavectA.balanceOf(OWNER), 0);
        vm.startPrank(OWNER);
        wavectA.mint(OWNER_PROOF);
        assertEq(wavectA.balanceOf(OWNER), 1);
        assertEq(wavectA.ownerOf(firstTokenID), OWNER);
        vm.expectRevert("Already minted");
        wavectA.mint(OWNER_PROOF);
        vm.stopPrank();
        // used startPrank
    }

    function testOther2Mint() public {
        assertEq(wavectA.balanceOf(OTHER_2), 0);
        vm.startPrank(OTHER_2);
        wavectA.mint(OTHER_PROOF_2);
        assertEq(wavectA.balanceOf(OTHER_2), 1);
        assertEq(wavectA.ownerOf(firstTokenID), OTHER_2);
        vm.expectRevert("Already minted");
        wavectA.mint(OTHER_PROOF_2);
        vm.stopPrank();
        // used startPrank
    }

    function testOwnerIncreaseRank() public {
        vm.prank(NONOWNER);
        wavectA.mint(NONOWNER_PROOF);
        assertEq(wavectA.balanceOf(NONOWNER), 1);

        vm.startPrank(OWNER);
        assertEq(wavectA.communityRank(firstTokenID), 0);
        wavectA.increaseRank(firstTokenID);
        assertEq(wavectA.communityRank(firstTokenID), 1);

        vm.expectEmit(true, true, false, false);
        emit RankIncreased(firstTokenID, 2);
        wavectA.increaseRank(firstTokenID);
        assertEq(wavectA.communityRank(firstTokenID), 2);
        vm.stopPrank();
    }

    function testOwnerDecreaseRank() public {
        vm.prank(NONOWNER);
        wavectA.mint(NONOWNER_PROOF);
        assertEq(wavectA.balanceOf(NONOWNER), 1, "Mint failed");
        vm.startPrank(OWNER);
        assertEq(wavectA.communityRank(firstTokenID), 0, "Initial rank wrong");
        wavectA.increaseRank(firstTokenID);
        assertEq(wavectA.communityRank(firstTokenID), 1, "Rank increase failed");

        vm.expectEmit(true, true, false, false);
        emit RankDecreased(firstTokenID, 1);
        wavectA.decreaseRank(firstTokenID);
        assertEq(wavectA.communityRank(firstTokenID), 0, "Decrease failed");
        vm.stopPrank();
    }

    function testOwnerResetRank() public {
        vm.prank(NONOWNER);
        wavectA.mint(NONOWNER_PROOF);
        assertEq(wavectA.balanceOf(NONOWNER), 1);
        vm.startPrank(OWNER);
        assertEq(wavectA.communityRank(firstTokenID), 0);
        wavectA.increaseRank(firstTokenID);
        wavectA.increaseRank(firstTokenID);
        assertEq(wavectA.communityRank(firstTokenID), 2);

        vm.expectEmit(true, false, false, false);
        emit RankReset(firstTokenID);
        wavectA.resetRank(firstTokenID);
        assertEq(wavectA.communityRank(firstTokenID), 0);
        vm.stopPrank();
    }

    function testMintEnabled() public {
        assertEq(wavectA.paused(), false);

        vm.prank(NONOWNER);
        wavectA.mint(NONOWNER_PROOF);
        vm.prank(OWNER);
        wavectA.setDisableMint(true);

        vm.expectRevert("Pausable: paused");
        vm.prank(OTHER);
        wavectA.mint(OTHER_PROOF);

        vm.expectRevert("Pausable: paused");
        vm.prank(OTHER_2);
        wavectA.claimRewardNFT(0, 0, OWNER_SIG_EXAMPLE);
    }

    function testTotalSupply() public {
        assertEq(wavectA.totalSupply(), 100, "Invalid total supply (1)");
        vm.startPrank(OWNER);
        vm.expectRevert("Cannot be smaller");
        wavectA.setTotalSupply(2);

        wavectA = new Wavect(L0_ENDPOINT_DUMMY, "https://wavect.io/official-nft/contract-metadata.json", "https://wavect.io/official-nft/metadata/1.json?debug=",
            "Wavect", "WACT", ".json", 2, MERKLE_ROOT, false);
        // for custom supply

        assertEq(wavectA.totalSupply(), 2, "Invalid total supply (2)");
        wavectA.mint(OWNER_PROOF);
        assertEq(wavectA.balanceOf(OWNER), 1);
        assertEq(wavectA.ownerOf(firstTokenID), OWNER);
        vm.stopPrank();
        vm.prank(NONOWNER);
        wavectA.mint(NONOWNER_PROOF);
        assertEq(wavectA.balanceOf(NONOWNER), 1);
        assertEq(wavectA.ownerOf(firstTokenID + 1), NONOWNER);
        vm.expectRevert("No more tokens available");
        vm.prank(OTHER);
        wavectA.mint(OTHER_PROOF);
        assertEq(wavectA.balanceOf(OTHER), 0);

        vm.startPrank(OWNER);
        wavectA.setTotalSupply(3);
        wavectA.freezeTotalSupply();
        vm.expectRevert("Supply frozen");
        wavectA.setTotalSupply(100);
        vm.stopPrank();

        vm.prank(OTHER);
        wavectA.mint(OTHER_PROOF);
        assertEq(wavectA.balanceOf(OTHER), 1);
        assertEq(wavectA.ownerOf(firstTokenID + 2), OTHER);

        vm.expectRevert("No more tokens available");
        vm.prank(OTHER_2);
        wavectA.mint(OTHER_PROOF_2);
    }

    function testMetadata() public {
        assertEq(wavectA.balanceOf(NONOWNER), 0);
        vm.prank(NONOWNER);
        wavectA.mint(NONOWNER_PROOF);
        assertEq(wavectA.balanceOf(NONOWNER), 1);
        assertEq(wavectA.ownerOf(firstTokenID), NONOWNER);

        string memory onchainMetadata = wavectA.tokenURI(firstTokenID);
        console.log(onchainMetadata);

        assertEq(wavectA.fileExt(), ".json");
        vm.prank(OWNER);
        wavectA.setFileExt("");
        assertEq(wavectA.fileExt(), "");

        string memory onchainMetadataFileExt = wavectA.tokenURI(firstTokenID);
        assert(keccak256(abi.encodePacked(onchainMetadata)) != keccak256(abi.encodePacked(onchainMetadataFileExt)));
        // must be different
    }

    function testWhitelist() public {
        assertEq(wavectA.balanceOf(OTHER_2), 0);
        vm.prank(OTHER_2);
        wavectA.mint(OTHER_PROOF_2);
        assertEq(wavectA.balanceOf(OTHER_2), 1);

        vm.startPrank(OWNER);
        vm.expectRevert("Invalid proof");
        wavectA.mint(NONOWNER_PROOF);
        vm.expectRevert("Invalid proof");
        wavectA.mint(FAULTY_PROOF);
        wavectA.setPublicSale(true);
        wavectA.mint(FAULTY_PROOF);
        vm.expectRevert("Already minted");
        wavectA.mint(FAULTY_PROOF);
        wavectA.safeTransferFrom(OWNER, NONOWNER, firstTokenID + 1);
        vm.expectRevert("Already minted");
        wavectA.mint(FAULTY_PROOF);
        vm.stopPrank();
    }

    function testPrice() public {
        assertEq(wavectA.balanceOf(OTHER_2), 0, "Should not have NFT (1)");
        vm.prank(OTHER_2);
        wavectA.mint(OTHER_PROOF_2);
        // for free
        assertEq(wavectA.balanceOf(OTHER_2), 1, "Should receive NFT (1)");
        assertEq(wavectA.mintPrice(), 0, "Should be free");
        assertEq(address(wavectA).balance, 0 ether, "Should not have balance");

        vm.prank(OWNER);
        wavectA.setMintPrice(0.1 ether);
        assertEq(wavectA.balanceOf(OWNER), 0, "Should not have NFT (2)");
        vm.expectRevert("Payment too low");
        vm.prank(OWNER);
        wavectA.mint(OWNER_PROOF);
        assertEq(wavectA.balanceOf(OWNER), 0, "Should not have NFT (3)");

        vm.deal(OWNER, 0.1 ether);
        vm.prank(OWNER);
        wavectA.mint{value : 0.1 ether}(OWNER_PROOF);
        assertEq(wavectA.balanceOf(OWNER), 1, "Should receive NFT (2)");
        assertEq(address(wavectA).balance, 0.1 ether, "Should have paid (1)");
        assertEq(address(OWNER).balance, 0 ether, "Should have nothing left (1)");

        vm.deal(OTHER, 0.15 ether);
        vm.prank(OTHER);
        wavectA.mint{value : 0.15 ether}(OTHER_PROOF);
        assertEq(wavectA.balanceOf(OTHER), 1, "Should receive NFT (3)");
        assertEq(address(wavectA).balance, 0.2 ether, "Should have paid (2)");
        // 2nd mint
        assertEq(address(OTHER).balance, 0.05 ether, "Should have gotten refund (1)");

        assertEq(address(OWNER).balance, 0 ether, "Should have nothing left (2)");
        assertEq(address(wavectA).balance, 0.2 ether, "Should have balance on contract (1)");
        vm.prank(OWNER);
        wavectA.withdrawRevenue();
        assertEq(address(OWNER).balance, 0.2 ether, "Should receive payment (1)");
        assertEq(address(wavectA).balance, 0 ether, "Should not have a balance on contract (1)");

    }

    function testWithdraw() public {
        vm.prank(OWNER);
        wavectA.setMintPrice(1 ether);

        vm.deal(OTHER, 1 ether);
        vm.prank(OTHER);
        wavectA.mint{value : 1 ether}(OTHER_PROOF);
        assertEq(wavectA.balanceOf(OTHER), 1);
        assertEq(address(OTHER).balance, 0 ether);
        assertEq(address(wavectA).balance, 1 ether);

        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(OTHER_2);
        wavectA.withdrawRevenue();

        assertEq(address(OWNER).balance, 0 ether, "Should have nothing (1)");
        assertEq(address(wavectA).balance, 1 ether, "Should have balance on contract (1)");
        vm.prank(OWNER);
        wavectA.withdrawRevenue();
        assertEq(address(OWNER).balance, 1 ether, "Should receive payment (1)");
        assertEq(address(wavectA).balance, 0 ether, "Should not have a balance on contract (1)");
    }

    function testOverPayment() public {
        vm.prank(OWNER);
        wavectA.setMintPrice(0.1 ether);
        assertEq(wavectA.balanceOf(OWNER), 0);

        vm.deal(OTHER, 1 ether);
        vm.prank(OTHER);
        wavectA.mint{value : 1 ether}(OTHER_PROOF);
        assertEq(wavectA.balanceOf(OTHER), 1);
        assertEq(address(OTHER).balance, 0.9 ether);
        assertEq(address(wavectA).balance, 0.1 ether);

        assertEq(address(OWNER).balance, 0 ether, "Should have nothing (1)");
        assertEq(address(wavectA).balance, 0.1 ether, "Should have balance on contract (1)");
        vm.prank(OWNER);
        wavectA.withdrawRevenue();
        assertEq(address(OWNER).balance, 0.1 ether, "Should receive payment (1)");
        assertEq(address(wavectA).balance, 0 ether, "Should not have a balance on contract (1)");
    }

    function testPausable() public {
        assertEq(wavectA.balanceOf(NONOWNER), 0);
        vm.startPrank(NONOWNER);
        wavectA.mint(NONOWNER_PROOF);
        assertEq(wavectA.balanceOf(NONOWNER), 1);
        assertEq(wavectA.ownerOf(firstTokenID), NONOWNER);
        vm.stopPrank();

        vm.prank(OWNER);
        wavectA.setDisableMint(true);
        assertEq(wavectA.balanceOf(OWNER), 0);
        vm.expectRevert("Pausable: paused");
        wavectA.mint(OWNER_PROOF);

        vm.expectRevert("Pausable: paused");
        wavectA.claimRewardNFT(firstTokenID, 0, "");
    }

    function testImproveTokens() public {
        assertEq(wavectA.RESERVED_TOKENS(), 3, "Unexpected amount of reserved tokens");
        assertEq(wavectA.SOLIDARITY_ID(), 0, "Unexpected Solidarity ID");
        assertEq(wavectA.ENVIRONMENT_ID(), 1, "Unexpected Environment ID");
        assertEq(wavectA.HEALTH_ID(), 2, "Unexpected Health ID");

        vm.startPrank(NONOWNER);
        wavectA.mint(NONOWNER_PROOF);
        assertEq(wavectA.balanceOf(NONOWNER), 1);
        assertEq(wavectA.ownerOf(firstTokenID), NONOWNER);
        assertEq(firstTokenID, 3);

        assertEq(wavectA.usedRewardClaimNonces(0), false, "Nonce already used");
        vm.stopPrank();

        vm.expectRevert("Invalid voucher");
        vm.prank(OTHER);
        wavectA.claimRewardNFT(0, 0, OWNER_SIG_EXAMPLE);
        assertEq(wavectA.usedRewardClaimNonces(0), false, "Nonce already used");

        vm.expectRevert("Invalid voucher");
        vm.prank(OTHER_2);
        wavectA.claimRewardNFT(0, 0, FAULTY_SIG_EXAMPLE);
        assertEq(wavectA.usedRewardClaimNonces(0), false, "Nonce already used");

        console.log(string(abi.encodePacked()));
        vm.prank(OTHER_2);
        wavectA.claimRewardNFT(0, 0, OWNER_SIG_EXAMPLE);
        assertEq(wavectA.usedRewardClaimNonces(0), true, "Nonce not used");
        assertEq(wavectA.balanceOf(OTHER_2), 1);
        assertEq(wavectA.ownerOf(0), OTHER_2);

        vm.expectRevert("Nonce used");
        vm.prank(OTHER_2);
        wavectA.claimRewardNFT(0, 0, OWNER_SIG_EXAMPLE);

        vm.expectRevert("Not reward token");
        vm.prank(OTHER_2);
        wavectA.claimRewardNFT(firstTokenID, 0, OWNER_SIG_EXAMPLE);

        assertEq(wavectA.usedRewardClaimNonces(1), false, "Nonce already used");
        vm.expectRevert("Invalid voucher");
        vm.prank(OTHER_2);
        wavectA.claimRewardNFT(0, 1, OWNER_SIG_EXAMPLE);


        string memory onchainMetadata = wavectA.tokenURI(firstTokenID);
        console.log(onchainMetadata);

        string memory onchainMetadataSpecial = wavectA.tokenURI(0);
        console.log(onchainMetadataSpecial);

        assert(keccak256(abi.encodePacked(onchainMetadata)) != keccak256(abi.encodePacked(onchainMetadataSpecial)));
        // useful since non-revealed metadata is identical for regular tokens
        // must be different
    }

    function testIsApprovedAll() public {
        vm.startPrank(NONOWNER);
        assertEq(wavectA.isApprovedForAll(NONOWNER, OWNER), false, "Should not be approved (1)");
        wavectA.setApprovalForAll(OWNER, true);
        assertEq(wavectA.isApprovedForAll(NONOWNER, OWNER), true, "Should be approved (1)");
        wavectA.setApprovalForAll(OWNER, false);
        assertEq(wavectA.isApprovedForAll(NONOWNER, OWNER), false, "Should not be approved (2)");
        vm.stopPrank();
    }

    function testIsBelowMaxWallet() public {
        assertTrue(wavectA.isBelowMaxWallet(NONOWNER), "Above maxWallet (1)");
        vm.prank(NONOWNER);
        wavectA.mint(NONOWNER_PROOF);
        assertFalse(wavectA.isBelowMaxWallet(NONOWNER), "Below maxWallet (1)");

        vm.expectRevert("Already minted");
        vm.prank(NONOWNER);
        wavectA.mint(NONOWNER_PROOF);
    }

    function testIsWhitelisted() public {
        assertTrue(wavectA.isWhitelisted(NONOWNER, NONOWNER_PROOF), "Not Whitelisted (1)");
        assertFalse(wavectA.isWhitelisted(address(74), FAULTY_PROOF), "Whitelisted (1)");
    }

    event Received(uint);

    receive() external payable {
        emit Received(msg.value);
    }
}
