

# Description

This repository contains the tools for swapping ERC20 token in any UniswapV3Pools. 

The Quoter contract which has a view function that allows the users to get the swap qoutes from any UniswapV3Pool before actually swapping. User dont need to use any js staticcall libraries.

The Pot contract acts as a wallet for storing and swapping ERC20 tokens(in UniswapV3Pool). The owner will be the deployer who can only call every functions of the contract. uniswapV3SwapCallback function can only be called by the pool address provided by the owner as the parameter for swapping in the swap function.


# Repository Structure 

## Core Components

- **Quoter Contract** (`src/Quoter.sol`): The contract that has a view function to get swap quotes.
- **Pot** (`src/Pot.sol`): Implementation for swapping, storing, and withdraw ERC20 tokens. 

# Developer setup

## Installation 

### Clone the repository:

````bash
git clone https://github.com/vishwa7dcap786/UniswapV3QuoterView.git
cd UniswapV3QuoterView
curl -L https://foundry.paradigm.xyz | bash
forge init
````
### Compilation:

```bash
forge compile
```

### Scripts:

steps: 

    1.deploy() get qouterAddress from logs.
    2.getQuotes(qouterAddress, pool, zeroForOne, amount)

```bash
forge script script/Counter.s.sol:CounterScript --rpc-url http://127.0.0.1:8545 --broadcast --via-ir -vvvv

``` 
