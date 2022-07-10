// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "forge-std/Script.sol";
import "../src/Wavect.sol";

contract WavectScript is Script {
    bytes32 MERKLE_ROOT = 0x4356ad31af829c8a7305544d695feb2d676503330d33d508a300302544927853;
    // 0x4b9b7bd8954465814783765fa5c3fcc4cc039608c42c2c343a5c8fab384ccc88
    // 0xad69fb1ac598decabf37422d2ee770fcd8fa569889e3de5dc306229f407bfa35

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        Wavect wavect = new Wavect("https://wavect.io/official-nft/contract-metadata.json", "https://wavect.io/official-nft/logo_square.jpg", "Wavect",
            "This NFT can be used to vote on podcast guests, topics and many other things. We also plan to release products in the near future, this NFT will give you then a lifelong rebate and gives you access to our Improve-the-World campaign.",
            "https://wavect.io?nft=true", "https://wavect.io/official-nft/wavect_video.mp4", ".jpg", 100, MERKLE_ROOT);

        vm.stopBroadcast();
    }
}
