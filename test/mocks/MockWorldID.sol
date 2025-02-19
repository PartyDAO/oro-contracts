// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {IWorldID} from "src/interfaces/IWorldID.sol";

contract MockWorldID is IWorldID {
    function verifyProof(
        uint256 root,
        uint256 groupId,
        uint256 signal,
        uint256 nullifierHash,
        uint256 externalNullifier,
        uint256[8] calldata proof
    ) external pure override {
        // Always succeed
    }
}
