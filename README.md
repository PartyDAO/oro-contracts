# Oro Contracts

This repository contains the smart contracts for the Oro (ORO) token on worldchain, a Sybil-resistant ERC20 token that uses World ID for proof of personhood. ORO can be claimed once a day by any user who has a valid World ID proof.

## Overview

Oro is an ERC20 token with a unique minting mechanism that requires World ID verification, ensuring that tokens can only be minted by real human users. The contract implements a time-gated minting system where verified users can mint a fixed amount of tokens periodically.

## Features

- **World ID Integration**: Uses World ID for Sybil resistance and proof of personhood
- **Time-Gated Minting**: Configurable waiting period between mints for each user
- **Fixed Mint Amount**: Each successful mint yields a configurable amount of tokens
- **Owner Controls**: Authorized owner can adjust mint amounts and waiting periods

## Contract Details

### Key Parameters

- **Token Name**: ORO
- **Token Symbol**: ORO
- **Minting System**:
  - 1 ORO per mint
  - Required wait time between mints is 24hrs
  - Requires World ID verification proof
  - Tracks mint history per nullifier hash

### Key Functions

- `mint(uint256 root, uint256 nullifierHash, uint256[8] calldata proof)`: Mint new tokens with World ID verification
- `setAmountPerMint(uint256 _amountPerMint)`: Update the amount of tokens per mint (owner only)
- `setWaitBetweenMints(uint40 _waitBetweenMints)`: Update the required wait time between mints (owner only)

## Development

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- [Git](https://git-scm.com/downloads)

### Setup

1. Clone the repository:
```bash
git clone https://github.com/PartyDAO/oro-contracts
cd oro-contracts
```

2. Install dependencies:
```bash
forge install
```

### Building

```bash
forge build
```

### Testing

```bash
forge test
```

## Dependencies

- OpenZeppelin Contracts (ERC20, Ownable)
- World ID Interface
- ByteHasher utility

## License

MIT License

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

```bash
forge install
```

