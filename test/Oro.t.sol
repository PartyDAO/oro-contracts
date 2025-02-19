// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test} from "forge-std/Test.sol";
import {MockWorldID} from "test/mocks/MockWorldID.sol";
import {IWorldID} from "src/interfaces/IWorldID.sol";
import {ORO} from "src/ORO.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract OROTest is Test {
    ORO MAGIC;
    IWorldID WORLD_ID_MOCK;

    address OWNER = makeAddr("owner");
    address USER = makeAddr("user");

    uint256 DEFAULT_ROOT;
    uint256 DEFAULT_NULLIFIER_HASH;
    uint256[8] DEFAULT_PROOF;

    function setUp() public {
        WORLD_ID_MOCK = new MockWorldID();
        MAGIC = new ORO(OWNER, WORLD_ID_MOCK, "APP_ID", "ACTION_ID", 1e18, 24 hours);
        vm.warp(1704070800); // 2024-01-01
    }

    function test_mint_success() public {
        vm.prank(USER);
        MAGIC.mint(DEFAULT_ROOT, DEFAULT_NULLIFIER_HASH, DEFAULT_PROOF);
        assertEq(MAGIC.balanceOf(USER), 1e18);
        (uint40 lastMintedAt, uint32 numOfMints) = MAGIC.nullifierHashMintData(DEFAULT_NULLIFIER_HASH);
        assertEq(lastMintedAt, uint40(block.timestamp));
        assertEq(numOfMints, 1);
    }

    function test_mint_revert_notEnoughTimeHasPassed() public {
        test_mint_success();
        uint256 lastMintedAt = block.timestamp;
        vm.warp(lastMintedAt + MAGIC.waitBetweenMints() - 1);
        vm.expectRevert(
            abi.encodeWithSelector(ORO.ORO__NotEnoughTimeHasPassed.selector, lastMintedAt, MAGIC.waitBetweenMints())
        );
        vm.prank(USER);
        MAGIC.mint(DEFAULT_ROOT, DEFAULT_NULLIFIER_HASH, DEFAULT_PROOF);
    }

    function test_setAmountPerMint_asOwner() public {
        vm.prank(OWNER);
        MAGIC.setAmountPerMint(2e18);
        assertEq(MAGIC.amountPerMint(), 2e18);
    }

    function test_setAmountPerMint_asNonOwner(address nonOwner) public {
        vm.assume(nonOwner != OWNER);
        vm.prank(nonOwner);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, nonOwner));
        MAGIC.setAmountPerMint(2e18);
    }

    function test_setWaitBetweenMints_asOwner() public {
        vm.prank(OWNER);
        MAGIC.setWaitBetweenMints(7200);
        assertEq(MAGIC.waitBetweenMints(), 7200);
    }

    function test_setWaitBetweenMints_asNonOwner(address nonOwner) public {
        vm.assume(nonOwner != OWNER);
        vm.prank(nonOwner);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, nonOwner));
        MAGIC.setWaitBetweenMints(7200);
    }
}
