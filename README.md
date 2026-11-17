# Uniswap v2 DEX

Decentralized exchange (DEX) based on the Uniswap v2 automated market maker (AMM) model. Implements a constant product formula (x·y=k) with liquidity pool tokens, fee distribution, and slippage protection.

## Features

- **Factory Contract**: Deterministic pair creation using CREATE2
- **Pair Contract**: Core AMM with constant product invariant (x·y=k), LP token minting/burning, and 0.3% fee mechanism
- **Router Contract**: Stateless entry point for swaps and liquidity operations with slippage protection
- **Security First**: Hybrid reentrancy defense (optimistic transfers + k-check + OpenZeppelin ReentrancyGuard)
- **Gas Optimized**: Storage packing, unchecked math where safe, minimal external calls
- **Comprehensive Testing**: Unit tests, integration tests, and invariant fuzzing with Foundry

## Tech Stack

- **Smart Contracts**: Solidity ^0.8.24
- **Framework**: Foundry (forge, anvil, cast)
- **Libraries**: OpenZeppelin Contracts
- **Testing**: forge test + forge fuzz
- **CI/CD**: GitHub Actions with automated releases

## Project Structure

```
contracts/
├── src/
│   ├── Factory.sol          # Pair creation and registry
│   ├── Pair.sol             # AMM core + LP token (ERC20)
│   ├── Router.sol           # User entry point
│   ├── interfaces/          # Contract interfaces
│   └── libraries/           # Math utilities
├── test/
│   ├── Factory.t.sol
│   ├── Pair.t.sol
│   ├── Router.t.sol
│   └── Integration.t.sol
├── script/
│   └── Deploy.s.sol
└── foundry.toml
```

## Getting Started

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Git

### Installation

```bash
# Clone the repository
git clone <your-repo-url>
cd contracts

# Install dependencies
forge install

# Build contracts
forge build
```

### Testing

```bash
# Run all tests
forge test

# Run with verbose output
forge test -vvv

# Run specific test contract
forge test --match-contract PairTest

# Run with gas report
forge test --gas-report

# Run coverage
forge coverage --report summary
```

### Local Development

```bash
# Start local Anvil node
anvil

# Deploy to local network (in another terminal)
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast
```

## Versioning

This project follows semantic versioning with milestone releases per phase:

| Version | Phase | Description |
|---------|-------|-------------|
| v0.1.0 | Foundation | Toolchain setup, interfaces, math libraries |
| v0.2.0 | Pair AMM | Core AMM, LP tokens, pricing library |
| v0.3.0 | Factory + Router | CREATE2 pairs, slippage protection |
| v0.4.0 | Verification | Integration tests, fuzzing, gas optimization |
| v1.0.0 | Stable | Production-ready with full documentation |

## Architecture Decisions

- **Pure Foundry**: No Hardhat — unified stack with native fuzzing
- **Immutable Protocol**: No admin keys, no protocol fees in MVP
- **Hybrid Reentrancy**: Optimistic transfers + k-check (Pair) + ReentrancyGuard (Router)
- **LP Token Embedding**: Custom ERC20 in Pair contract (~20% gas savings)

## Security

This project implements multiple security layers:

- Reentrancy protection via k-invariant check
- Overflow/underflow protection (Solidity 0.8.x native + unchecked where safe)
- Slippage protection with deadline validation
- Oracle manipulation mitigation (TWAP-ready design)

**Known Limitations**:
- Fee-on-transfer tokens NOT supported
- Rebasing tokens NOT supported
- MEV/front-running risks inherent to public AMMs

## Contributing

This project uses the Socratic mentor workflow:

1. Core logic written by contributors (learning-by-doing)
2. Tests created by mentor, reviewed together
3. All changes go through feature branches → PR to `develop`
4. Automated releases from `develop` → `main`

Before contributing, read `spec.md` for the full roadmap and architecture decisions.

## Roadmap

### Post-MVP (v1.0.0+)
- [ ] TWAP oracle integration
- [ ] Flash swap support
- [ ] Protocol fee mechanism (feeToSetter)
- [ ] Multi-hop path optimization
- [ ] Frontend DApp (React + Wagmi)
- [ ] Go indexer for event streaming

## License

MIT License - see [LICENSE](LICENSE) for details

## Acknowledgments

- [Uniswap v2](https://uniswap.org/) — Original protocol design
- [Foundry](https://getfoundry.sh/) — Development framework
- [OpenZeppelin](https://openzeppelin.com/) — Security libraries

---

**Status**: 🚧 In active development (Phase 1: Foundation)
