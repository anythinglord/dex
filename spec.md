# Uniswap v2 DEX — Spec & Roadmap

## 1. Purpose

Build a decentralized AMM-style DEX modeled after Uniswap v2, designed as a high-performance open-source portfolio project. Clean architecture, modular, gas-optimized, with emphasis on security and maintainability.

## 2. Contract Architecture

### 2.1 Factory
- Creates and registers token pairs deterministically (CREATE2)
- Maintains a `tokenA => tokenB => pair` mapping
- Emits events with indexed parameters for the indexer
- Immutable after deployment (no admin, no upgrades)

### 2.2 Pair
- Implements the constant product curve: `x * y = k`
- Calculates fees (0.3% standard) for liquidity providers
- Mints and burns LP tokens (ERC20)
- Protected against reentrancy (optimistic transfer + k-check)
- Exposes internal price for oracle (TWAP)

### 2.3 Router
- User-facing entry point
- Handles swaps (single-hop, multi-hop)
- Slippage protection (amountOutMin, deadline)
- Calculates expected amounts before execution
- Stateless (no state maintained)

## 3. Tech Stack

- **Language:** Solidity ^0.8.24
- **Framework:** Foundry (forge, anvil, cast)
- **Libraries:** OpenZeppelin (AccessControl, ReentrancyGuard, ERC20)
- **Testing:** `forge test` + native fuzzing
- **Deploy:** `forge script`

## 4. Critical Invariants

### 4.1 Constant Product Invariant
```
k = reserve0 * reserve1
After a swap: k' >= k (can only grow due to fees)
```

### 4.2 LP Token Accounting
```
Total supply = sum of all LP tokens
Liquidity added => proportional LP minted
Liquidity removed => proportional LP burned
```

### 4.3 Slippage Protection
```
amountOut >= amountOutMin (revert if false)
block.timestamp <= deadline (revert if expired)
```

## 5. Security

### 5.1 Reentrancy
- Pattern: optimistic transfer + post-callback k-check
- Never trust external calls before updating internal state
- Use OpenZeppelin `nonReentrant` where applicable

### 5.2 Oracle Manipulation
- Do not use spot price as sole oracle
- Implement TWAP (Time-Weighted Average Price)
- Document limitations for users

### 5.3 Front-Running
- Deadline parameter to limit attack window
- User-configurable slippage tolerance
- Document that MEV is inherent to public AMMs

## 6. Gas Optimization

- Storage packing (group variables < 32 bytes)
- Unchecked math where safe (post-0.8.0 overflow checks)
- Minimal external calls
- Event emission with indexed parameters
- CREATE2 for pair addresses (avoids SSTORE in Factory)

## 7. Testing Strategy

### 7.1 Unit Tests
- Each public function with happy path tests
- Edge cases: zero amounts, max uint256, reentrancy attempts
- Coverage target: >95%

### 7.2 Integration Tests
- Full flows: addLiquidity → swap → removeLiquidity
- Multi-hop swaps (A → B → C)
- Correct fee calculations

### 7.3 Fuzzing
- Fuzz inputs: amounts, deadlines, reserves
- Invariant testing: k' >= k after any operation
- Adversarial scenarios: flash loans, sandwich attacks

## 8. File Structure

```
contracts/
├── src/
│   ├── Factory.sol
│   ├── Pair.sol
│   └── Router.sol
├── test/
│   ├── Factory.test.sol
│   ├── Pair.test.sol
│   ├── Router.test.sol
│   └── Integration.test.sol
├── script/
│   ├── Deploy.s.sol
│   └── Interact.s.sol
└── foundry.toml
```

## 9. Interfaces

### 9.1 IFactory
```solidity
function createPair(address tokenA, address tokenB) external returns (address pair);
function getPair(address tokenA, address tokenB) external view returns (address pair);
function allPairs(uint) external view returns (address pair);
function allPairsLength() external view returns (uint);
```

### 9.2 IPair
```solidity
function mint(address to) external returns (uint liquidity);
function burn(address to) external returns (uint amount0, uint amount1);
function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
```

### 9.3 IRouter
```solidity
function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
function removeLiquidity(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB);
function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
```

## 10. Acceptance Criteria (MVP)

- ✅ Factory creates pairs deterministically (CREATE2)
- ✅ Pair implements x*y=k correctly
- ✅ Pair mints/burns LP tokens proportionally
- ✅ Router executes swaps with slippage protection
- ✅ All tests pass (`forge test`)
- ✅ Fuzzing finds 0 critical bugs
- ✅ Gas optimized (< 150k for single-hop swap)
- ✅ Code documented (NatSpec)
- ✅ No reentrancy vulnerabilities

## 11. Versioning Strategy

### Version Mapping
| Phase | Version | Scope |
|-------|---------|-------|
| Phase 1: Foundation | `v0.1.0` | Toolchain, interfaces, math libraries |
| Phase 2: Pair AMM | `v0.2.0` | Core AMM + LP tokens + pricing lib |
| Phase 3: Factory + Router | `v0.3.0` | CREATE2 + slippage + deploy |
| Phase 4: Verification | `v0.4.0` | Integration, fuzzing, gas, docs |
| Post-MVP (stable) | `v1.0.0` | Mainnet-ready, audit, full docs |

### Semantic Versioning Rules
- **Minor versions** (v0.x.0): Each phase adds new functionality
- **Major version** (v1.0.0): Post-MVP stable release for production
- **Patch versions** (v0.x.y): Bug fixes on existing phases (if needed)

## 12. CI/CD & Release Automation

### Conventional Commits
All commits follow Conventional Commits specification:
- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation changes
- `chore:` Tooling, config, dependencies
- `test:` Test additions/changes
- `refactor:` Code refactoring

### GitHub Actions Workflows

#### 1. CI Pipeline (`.github/workflows/ci.yml`)
Triggers on: push to any branch, PR to develop/main
```yaml
- forge build (compilation check)
- forge test (unit + integration tests)
- forge coverage --report summary (coverage ≥ 95%)
- forge test --gas-report (gas benchmark)
```

#### 2. Develop Branch (`.github/workflows/develop.yml`)
Triggers on: push to `develop`
```yaml
- Run full test suite
- Generate changelog with git-cliff
- Commit updated CHANGELOG.md back to develop
```

#### 3. Release to Main (`.github/workflows/release.yml`)
Triggers on: push to `main`
```yaml
- Run full test suite
- Auto-detect version from conventional commits (semantic-release)
- Create git tag (v0.1.0, v0.2.0, etc.)
- Generate release notes from changelog
- Create GitHub Release with tag
```

### Changelog Generation
**Tool**: `git-cliff` (Rust-based, fast, Conventional Commits native)

Config: `cliff.toml` in repo root
```bash
# Manual generation (if needed)
git cliff --tag v0.2.0 --output CHANGELOG.md
```

### Release Flow
1. Feature branch → PR to `develop`
2. Merge to `develop` → CI runs → changelog auto-updated
3. `develop` → PR to `main` (release PR)
4. Merge to `main` → auto-tag (v0.x.0) → GitHub Release created
5. Tag triggers deployment workflow (if applicable)

## 13. Testing Workflow (Mentor Mode)

### Test Creation Process
1. **User implements core logic** (e.g., `mint(to)` function)
2. **Mentor reviews** → provides feedback via hint ladder (5 levels)
3. **User corrects** until logic is correct
4. **Mentor creates tests** (unit tests for the function)
5. **User reviews tests** → audit together
6. **Move to next subtask**

### Test Types
- **Unit tests**: Each public function with happy path + edge cases
- **Integration tests**: Full flows (addLiquidity → swap → removeLiquidity)
- **Fuzzing**: Invariant testing (`k' >= k`, LP supply bounds, reserve consistency)
- **Gas benchmarks**: `forge test --gas-report` for optimization

### What Mentor Does Without Asking
- Bookkeeping (foundry.toml, remappings, CI config)
- Interface stubs
- Bookkeeping tests (non-core)
- Build errors, environment issues

### What User Does
- Core logic (x*y=k, LP mint/burn, swap math)
- Review mentor's tests and provide feedback
- Validate fuzzing invariants

## 14. Implementation Plan (MVP) — 4 Phases, 27 Tasks

### Phase 1: Foundation (PR 1) — ~650 lines

**Objective**: Toolchain, interfaces, math libraries. Compiles and is testable standalone.

- [ ] 1.1 `forge init --no-git --force` in `contracts/`; remove templates; `foundry.toml` (solc 0.8.24, optimizer 200, fuzz 10000)
- [ ] 1.2 Install OpenZeppelin; `remappings.txt` → `@openzeppelin/=lib/openzeppelin-contracts/`
- [ ] 1.3 `src/interfaces/`: IERC20, IFactory, IPair (+ERC20 subset, indexed events), IRouter, IWETH9 stub
- [ ] 1.4 `Math.sol` (min, sqrt), `SafeCast.sol` (reverting casts), `UQ112x112.sol` (encode/decode)
- [ ] 1.5 `test/Libraries.t.sol`: sqrt bounds, overflow reverts, UQ round-trip

**Done check**: `forge build` compiles warning-free, `forge test` passes with library tests.

---

### Phase 2: Pair AMM + LP ERC20 (PR 2) — ~900 lines

**Objective**: Core AMM with x*y=k curve, embedded LP tokens, pricing library.

- [ ] 2.1 `src/Pair.sol`: immutables factory/token0/token1, packed reserves+timestamp, custom LP storage
- [ ] 2.2 LP ERC20: approve/transfer/transferFrom, private `_mint`/`_burn` emitting `Transfer`
- [ ] 2.3 `getReserves`, `_update`, `_safeTransfer`, `MINIMUM_LIQUIDITY = 1000`, `sync`, `skim`
- [ ] 2.4 `mint(to)`: balance deltas; first mint `sqrt(a0*a1)-1000` (1000 burned); else `min` proportional
- [ ] 2.5 `burn(to)`: proportional amounts, LP burn, transfers, revert on zero output
- [ ] 2.6 `swap(...)`: output guard, optimistic transfer, `uniswapV2Call`, post-callback `k' ≥ k`
- [ ] 2.7 `UniswapV2Library.sol`: sortTokens, pairFor (CREATE2), quote, getAmountOut floor, getAmountIn ceil
- [ ] 2.8 `test/Pair.t.sol`: mint/burn/swap/fee/k-violation/1000 guard/overflow/flash-swap
- [ ] 2.9 `test/LibraryPricing.t.sol`: rounding direction, sortTokens, pairFor match

**Done check**: `forge test --match-contract PairTest` passes, LP mint/burn works, swap with 0.3% fee correct.

---

### Phase 3: Factory + Router (PR 3) — ~850 lines

**Objective**: CREATE2 pair creation, stateless Router with slippage protection, deploy script.

- [ ] 3.1 `src/Factory.sol`: derived `INIT_CODE_HASH` from `type(Pair).creationCode`, sorted salt, `create2`, `PAIR_EXISTS` check, registry
- [ ] 3.2 `test/Factory.t.sol`: address vs `vm.computeCreate2Address`, duplicates, normalized lookup, event
- [ ] 3.3 `src/Router.sol`: immutable factory, `ensure(deadline)` → `EXPIRED`, OZ `ReentrancyGuard`, ERC20 only (no ETH/WETH)
- [ ] 3.4 `addLiquidity`/`removeLiquidity`: transferFrom, optimal amounts, LP to `to`, minimums validation
- [ ] 3.5 `swapExactTokensForTokens`/`swapTokensForExactTokens`: path loop, `amountOutMin`; `getAmountsOut/In` views
- [ ] 3.6 `test/Router.t.sol`: slippage revert, expired deadline, minimum violations, statelessness
- [ ] 3.7 `script/Deploy.s.sol`: deploy Factory, log address

**Done check**: `forge test --match-contract FactoryTest` and `RouterTest` pass, deploy script works on anvil.

---

### Phase 4: Verification + Docs (PR 4) — ~800 lines

**Objective**: Integration tests, invariant fuzzing, gas benchmark, documentation.

- [ ] 4.1 `test/Integration.t.sol`: create→add→swap→remove; multi-hop A→B→C; dust provider reverts
- [ ] 4.2 `PairHandler.sol` + `test/invariant/PairInvariants.t.sol`: `k' ≥ k`, LP supply, reserve bounds
- [ ] 4.3 Assert Factory/lib hash == `keccak256(type(Pair).creationCode)` — integrity verification
- [ ] 4.4 `forge test --gas-report`: swap < 150k; tune `unchecked`/packing if exceeded
- [ ] 4.5 NatSpec on all public/external functions; `forge build` warning-free; coverage ≥ 95%
- [ ] 4.6 `SECURITY.md` + `README.md`: unsupported tokens (fee-on-transfer, rebasing), MEV/oracle limits, commands, gas table

**Done check**: `forge test` passes, `forge test --fuzz-runs 10000` with zero violations, swap < 150k gas, coverage ≥ 95%.

---

### MVP Finish Line

When all these commands pass without errors:
```bash
forge build --sizes
forge test
forge test --fuzz-runs 10000
forge coverage --report summary
```

And swap gas < 150k, **the MVP is done**.

Then offer: "You wrote these parts: [X, Y, Z]. Bonus round?"

## 15. Post-MVP (Optional)

### Phase 2: Oracle & Advanced Features
- TWAP oracle (price0CumulativeLast, price1CumulativeLast)
- Flash swap support (swap with callback)
- Sync function to force reserve updates

### Phase 3: Protocol Fee
- feeToSetter in Factory
- 1/6 of fee goes to feeTo address
- Admin functionality (setFeeTo)

### Phase 4: Multi-hop Optimization
- Path finding for complex swaps
- Gas refund for optimal routes
- Batch swaps

### Phase 5: Mainnet Deployment
- Audit (if production-bound)
- Deploy to testnet (Sepolia)
- Verify contracts on Etherscan
- Public documentation

### Phase 6: Frontend & Indexer
- React DApp with Wagmi + Viem
- Go indexer for events
- GraphQL API for queries

## 16. Architecture Decisions

### 16.1 Tooling
- **Decision:** Pure Foundry (no Hardhat)
- **Reason:** Native forge test + forge fuzz, faster, unified stack
- **Trade-off:** Loses compatibility with monorepo (which uses Hardhat), but gains speed and simplicity

### 16.2 Protocol Fee
- **Decision:** Immutable (no protocol fee in MVP)
- **Reason:** Simplicity, no admin keys, more decentralized
- **Trade-off:** No revenue for future maintenance, but philosophically purer
- **Post-MVP:** feeToSetter can be added as optional upgrade

### 16.3 Reentrancy Defense
- **Decision:** Hybrid (optimistic transfer + k-check + OZ ReentrancyGuard)
- **Reason:** Defense in depth, follow Uniswap v2 canonical pattern
- **Trade-off:** Slightly more gas, but critical security

### 16.4 Versioning & Release
- **Decision:** Semantic versioning per phase (v0.1.0 → v0.4.0), auto-tag on main
- **Reason:** Clear milestones, automated releases, easy rollback per phase
- **Trade-off:** Requires CI/CD setup upfront, but saves manual work later
- **Flow:** develop accumulates changelog → main creates tag + GitHub Release

### 16.5 Changelog Automation
- **Decision:** git-cliff (Rust-based, fast, Conventional Commits native)
- **Reason:** Minimal config, fast generation, integrates with semantic-release
- **Trade-off:** Another dependency, but lightweight and proven

### 16.6 CI/CD Strategy
- **Decision:** GitHub Actions with 3 workflows (CI, develop, release)
- **Reason:** Native GitHub integration, free for public repos, easy to maintain
- **Trade-off:** Vendor lock-in to GitHub, but acceptable for open-source project

## 17. Risks and Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| CREATE2 hash mismatch | High | Derive init_code_hash from compiled bytecode, never hardcode |
| Fee-on-transfer tokens | High | Document + test that NOT supported |
| Oracle manipulation | Medium | Implement TWAP, document limitations |
| Front-running | Medium | Deadline + slippage tolerance (inherent to AMMs) |
| Fuzzing false confidence | Medium | Handlers must model adversaries, failing sequences → regression tests |

## 18. Documentation

- NatSpec on all public functions
- README.md with: what it is, how to deploy, how to test, architecture
- DIAGRAM.md with ASCII flow diagrams (addLiquidity, swap, removeLiquidity)
- SECURITY.md with known limitations and attack vectors
