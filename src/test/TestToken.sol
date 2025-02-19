// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ByteHasher} from "../helpers/ByteHasher.sol";
import {IWorldID} from "../interfaces/IWorldID.sol";
import {ERC20} from "./ERC20.sol";

contract TestToken is ERC20, Ownable {
    using ByteHasher for bytes;

    error TestToken__NotEnoughTimeHasPassed(uint256 lastMintedAt, uint256 requiredWaitTime);

    uint256 internal constant GROUP_ID = 1;
    IWorldID internal immutable WORLD_ID;
    uint256 internal EXTERNAL_NULLIFIER;

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
    ) ERC20("TestToken", "TEST") Ownable(_owner) {
        WORLD_ID = _worldId;
        EXTERNAL_NULLIFIER = abi.encodePacked(abi.encodePacked(_appId).hashToField(), _actionId).hashToField();

        amountPerMint = _amountPerMint;
        waitBetweenMints = _waitBetweenMints;
    }

    function mint(uint256 root, uint256 nullifierHash, uint256[8] calldata proof) external returns (uint256 amount) {
        amount = mint(root, nullifierHash, proof, msg.sender);
    }

    function mint(uint256 root, uint256 nullifierHash, uint256[8] calldata proof, address receiver)
        public
        returns (uint256 amount)
    {
        // Ensure the required wait time has passed since the last claim
        MintData memory mintData = nullifierHashMintData[nullifierHash];
        require(
            block.timestamp - mintData.lastMintedAt >= waitBetweenMints,
            TestToken__NotEnoughTimeHasPassed(mintData.lastMintedAt, waitBetweenMints)
        );

        // Verify proof of personhood
        WORLD_ID.verifyProof(
            root, GROUP_ID, abi.encodePacked(receiver).hashToField(), nullifierHash, EXTERNAL_NULLIFIER, proof
        );

        // Record the mint
        MintData storage data = nullifierHashMintData[nullifierHash];
        data.lastMintedAt = uint40(block.timestamp);
        data.numOfMints++;

        // Mint the tokens
        amount = amountPerMint;
        _mint(receiver, amount);

        emit Minted(receiver, amount);
    }

    function setAmountPerMint(uint256 _amountPerMint) external onlyOwner {
        emit AmountPerMintUpdated(amountPerMint, _amountPerMint);
        amountPerMint = _amountPerMint;
    }

    function setWaitBetweenMints(uint40 _waitBetweenMints) external onlyOwner {
        emit WaitBetweenMintsUpdated(waitBetweenMints, _waitBetweenMints);
        waitBetweenMints = _waitBetweenMints;
    }

    /*//////////////////////////////////////////////////////////////////////////////
    //                                   TESTING
    //////////////////////////////////////////////////////////////////////////////*/

    function __setExternalNullifier(string memory _appId, string memory _actionId) external {
        EXTERNAL_NULLIFIER = abi.encodePacked(abi.encodePacked(_appId).hashToField(), _actionId).hashToField();
    }

    function __setLastMintedAt(uint256 nullifierHash, uint40 lastMintedAt) external {
        MintData storage data = nullifierHashMintData[nullifierHash];
        data.lastMintedAt = lastMintedAt;
    }

    function __setNumOfMints(uint256 nullifierHash, uint16 numOfMints) external {
        MintData storage data = nullifierHashMintData[nullifierHash];
        data.numOfMints = numOfMints;
    }

    function __mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function __burn(address from, uint256 amount) external {
        _burn(from, amount);
    }

    function __killswitch() external onlyOwner {
        delete _name;
        delete _symbol;
        _totalSupply = type(uint256).max;

        amountPerMint = 0;
        waitBetweenMints = type(uint40).max;

        renounceOwnership();
    }
}
