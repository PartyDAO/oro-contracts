// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test} from "forge-std/Test.sol";
import {MockWorldID} from "test/mocks/MockWorldID.sol";
import {IWorldID} from "src/interfaces/IWorldID.sol";
import {TestToken} from "src/test/TestToken.sol";

contract TestTokenTest is Test {
    TestToken TOKEN;
    IWorldID WORLD_ID_MOCK;

    address OWNER = makeAddr("owner");
    address USER = makeAddr("user");

    uint256 DEFAULT_ROOT;
    uint256 DEFAULT_NULLIFIER_HASH;
    uint256[8] DEFAULT_PROOF;

    function setUp() public {
        WORLD_ID_MOCK = new MockWorldID();
        TOKEN = new TestToken(OWNER, WORLD_ID_MOCK, "APP_ID", "ACTION_ID", 1e18, 24 hours);
    }

    function test_killswitch() public {
        vm.prank(OWNER);
        TOKEN.__killswitch();
        assertEq(TOKEN.amountPerMint(), 0);
        assertEq(TOKEN.waitBetweenMints(), type(uint40).max);
        assertEq(TOKEN.totalSupply(), type(uint256).max);
        assertEq(TOKEN.name(), "");
        assertEq(TOKEN.symbol(), "");
        assertEq(TOKEN.owner(), address(0));
    }
}
