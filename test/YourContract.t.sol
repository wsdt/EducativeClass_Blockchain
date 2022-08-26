// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import "../src/YourContract.sol";
import "forge-std/console2.sol";

contract YourContractTest is Test {
    YourContract wavectA;
   
    function setUp() public {
        
    }

    function testInit() public {
        string memory a = "init";
        string memory b = "init";
        assertEq(a, b, "Init failed");
    }
}
