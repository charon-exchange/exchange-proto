## Free TON Constant Product Market Maker

### Features

- Supports TIP-3 tokens;
- Liquidity token for each trading pair;
- Token and pair lists based on the smart-contract;
- Governance and developer interfaces for changing fees, managing lists;
- Fully distributed approach;

### Warning: not audited, do not use in production!

### Composition
- RootTokenContract.(cpp|hpp) - modified [TIP-3](https://github.com/tonlabs/ton-labs-contracts/tree/master/cpp/tokens-fungible) Root token contract;
- TONTokenWallet.(cpp|hpp) - modified [TIP-3](https://github.com/tonlabs/ton-labs-contracts/tree/master/cpp/tokens-fungible) token wallet;
- CharonPair.sol - trading pair exchange contract;
- CharonPairList.sol - token & pair list contract;
- build.sh/clean.sh - building tools;
- test_*.sh - testing scripts;

### Installation
Build requires [TVM-compiler](https://github.com/tonlabs/TON-Compiler), [TVM-linker](https://github.com/tonlabs/TVM-linker), [TON-solidity-compiler](https://github.com/tonlabs/TON-Solidity-Compiler).

After installing these tools, run
```
./build.sh
```

### Testing
To test smart contracts, run the following commands:
```
./test_prepare.sh
```
This will clear previous files, compile smart contracts, generate keys, deploy contracts locally.

```
./test_tip3.sh
```
This will test TIP-3 contracts, namely:
- will make a mint and a grant tokens to the user wallet
- will transfer tokens from one wallet to another
- displays information about the status of wallets and root

```
./test_pair_list.sh
```
This will test the pair list smar-contract, namely:
- add tokens on behalf of the smart-contract owner
- will add a trade pair on behalf of the govarnance smart-contract
- will display the information stored in the smart-contract

```
./test_pair1.sh
```
This will test the exchange smart-contract, namely:
- will deposit tokens in a smart-contract and mint of liquidity tokens
- will request information about the exchange rate and fees
- will exchange one token for another
- will make a reverse exchange
- will burn and withdraw funds
- displays information about the state of the smart-contract and deposits of participants

### Notice
This repository was made for contest: 

[FreeTon DEX Architecture & Design Proposal](https://forum.freeton.org/t/contest-proposal-freeton-dex-architecture-design-proposal/3067)
