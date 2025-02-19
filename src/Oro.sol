// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ByteHasher} from "./helpers/ByteHasher.sol";
import {IWorldID} from "./interfaces/IWorldID.sol";

contract ORO is ERC20, Ownable {
    using ByteHasher for bytes;

    error ORO__NotEnoughTimeHasPassed(uint256 lastMintedAt, uint256 requiredWaitTime);

    uint256 internal constant GROUP_ID = 1;
    IWorldID internal immutable WORLD_ID;
    uint256 internal immutable EXTERNAL_NULLIFIER;

    uint256 public amountPerMint;
    uint40 public waitBetweenMints;

    struct MintData {
        uint40 lastMintedAt;
        uint32 numOfMints;
    }

    mapping(uint256 nullifierHash => MintData) public nullifierHashMintData;

    event Minted(address indexed to, uint256 amount);
    event AmountPerMintUpdated(uint256 oldAmount, uint256 newAmount);
    event WaitBetweenMintsUpdated(uint40 oldWait, uint40 newWait);

    constructor(
        address _owner,
        IWorldID _worldId,
        string memory _appId,
        string memory _actionId,
        uint256 _amountPerMint,
        uint40 _waitBetweenMints
    ) ERC20("ORO", "ORO") Ownable(_owner) {
        WORLD_ID = _worldId;
        EXTERNAL_NULLIFIER = abi.encodePacked(abi.encodePacked(_appId).hashToField(), _actionId).hashToField();

        amountPerMint = _amountPerMint;
        waitBetweenMints = _waitBetweenMints;
    }

    function mint(uint256 root, uint256 nullifierHash, uint256[8] calldata proof) public returns (uint256 amount) {
        // Ensure the required wait time has passed since the last claim
        MintData memory mintData = nullifierHashMintData[nullifierHash];
        require(
            block.timestamp - mintData.lastMintedAt >= waitBetweenMints,
            ORO__NotEnoughTimeHasPassed(mintData.lastMintedAt, waitBetweenMints)
        );

        // Verify proof of personhood
        WORLD_ID.verifyProof(
            root, GROUP_ID, abi.encodePacked(msg.sender).hashToField(), nullifierHash, EXTERNAL_NULLIFIER, proof
        );

        // Record the mint
        MintData storage data = nullifierHashMintData[nullifierHash];
        data.lastMintedAt = uint40(block.timestamp);
        data.numOfMints++;

        // Mint the tokens
        amount = amountPerMint;
        _mint(msg.sender, amount);

        emit Minted(msg.sender, amount);
    }

    function setAmountPerMint(uint256 _amountPerMint) external onlyOwner {
        emit AmountPerMintUpdated(amountPerMint, _amountPerMint);
        amountPerMint = _amountPerMint;
    }

    function setWaitBetweenMints(uint40 _waitBetweenMints) external onlyOwner {
        emit WaitBetweenMintsUpdated(waitBetweenMints, _waitBetweenMints);
        waitBetweenMints = _waitBetweenMints;
    }
}
