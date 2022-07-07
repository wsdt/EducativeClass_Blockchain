// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Wavect.sol";

contract WavectTest is Test {
    Wavect wavect;

    function setUp() public {
        wavect = new Wavect("https://wavect.io/official-nft/contract-metadata.json", "https://wavect.io/official-nft/logo_square.jpg", "Wavect",
        "This NFT can be used to vote on podcast guests, topics and many other things. We also plan to release products in the near future, this NFT will give you then either a lifelong rebate or even allows you to use our products for free.",
        "https://wavect.io?nft=true", "https://wavect.io/airdrop-ad/wavect_video.mp4");
    }

    function testExample() public {
        assertTrue(true);
    }
}
