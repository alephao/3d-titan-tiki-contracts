<p align="center">
  <img src="assets/logo.png" height="200" />
</p>

# 3D Titan Tiki

[![Lint, Test](https://github.com/alephao/3d-titan-tiki-contracts/actions/workflows/ci.yml/badge.svg)](https://github.com/alephao/3d-titan-tiki-contracts/actions/workflows/ci.yml)

> Deployed at [0x83fE3e51DB20982a8f4917738e130ce3eb7fEcAD](https://etherscan.io/address/0x83fE3e51DB20982a8f4917738e130ce3eb7fEcAD)

**3D Titan Tiki** is a NFT collection made of 2022 tiki. It is a sequel of the previous **Titan Tiki** nft collection. This repo contains everything used in the contract development phase as well as my thoughts and ideas used during development.

## High Level Specs and Business Logic

The contract is an ERC-1155 with only one instance of each token ID. The NFT metadata is stored off-chain and the sale has two stages: presale and public sale.

During the presale, addresses in the [allow-list](allowlist.json) are able to mint up to a specific amount of tokens for free. The allow-list was handed to me and is mostly composed of owners of the previous collection, we use a merkle tree to verify on-chain who can mint for free and how many.

The second step is the public sale, where anyone can mint a tiki by paying some eth. The unclaimed tiki from the "presale" are also available in the public sale, so if someone is not fast enough to claim their free tiki, they might not have the opportunity to claim anymore because someone else bought it.

### Release Plan

These are the functions that the contract driver will have to run:

1. Deploy contract (using the deployment script)
1. Reserve some nfts for the team `reserve(address,uint256)`
1. Start presale `setIsPresaleActive(bool)`
1. Start public sale `setIsSaleActive(bool)`
1. Set revealed baseURL `setURI(string)`
1. Withdraw Eth `withdraw()`

## Project

This project uses **[foundry](https://github.com/gakonst/foundry)** for building and testing. There is only one contract in this repo [TitanTiki3D.sol](src/TitanTiki3D.sol). The contract itself is not the most interesting since it is a pretty standard NFT contract, but the processess and tooling used during development are. In this readme you'll find all about it!

### Makefile

The [Makefile](Makefile) contains aliases for the commands I use the most, for example, during development I write some code and then run `make test` to run only the unit-tests. After adding/removing a new custom error I run `make codegen` to have it avaiable in the intellisense completion hints when writing tests. When optimizing I run `make snapshot && git diff .gas-snapshot` to see the results. Before commiting code, I would run `make format` to format the code, etc.

### Remappings

The [remappings.txt](remappings.txt) has a special remapping that I use a lot and find very useful which is `$/=src/`. This remapping let me import files in the following way:

```solidity
import { TitanTiki3D } from "$/TitanTiki3D.sol";

```

instead of

```solidity
import { TitanTiki3D } from "../../TitanTiki3D.sol";

```

This is handy especially in tests because I separate my tests in many files and during development I happen to change the directory structure few times. Some times I also copy/paste imports from one file to another, and with this I don't need to worry about relative paths. It's a small touch that makes me happier in these small interactions.

### Tests

The tests in this project are separated into three types `Benchmark`, `Unit`, and `E2E`.

**Test names**

I prefix each test with `test_` which is needed for `forge` to recognize it as a test. Next is the name of the function I'm testing like `mint` (my unit tests and benchmark tests are focused in a single function per test). Then I add an optional constraint like `WhenCallerIsNotOwner`. The test function name end up looking like this: `test_mint_WhenCallerIsNotOwner`, been working great for me in multiple projects. Easy to read, structured and descriptive.

**UnitTests** in this projects are tiny tests focused in a single function and usually follow the "arrange, act, assert" or "given, when, then". Each test starts by mocking a state, running a function, and making an assertion. I aim for 100% test coverage here. My process is to first figure out what I want to test without looking at the implementation, one way to do it is to write a bunch test names first, and fill them later:

```solidity
function test_foo() {
  revert NotImplemented();
}

function test_foo_WhenSomeSpecialCase() {
  revert NotImplemented();
}

function test_foo_WhenHacker() {
  revert NotImplemented();
}

function test_foo_WhenSomethingElse() {
  revert NotImplemented();
}

```

Then you can implement each test one by one, and to reduce noise I use the following command `forge test --match-test "test_foo_WhenSomeSpecialCase$"`.

After doing that, I look at the code and create tests for things I missed, for example, maybe I forgot to check a specific guard or a case where the code will branch out. The point is that at this point I use the code as a guide an try to make sure every line is covered.

An important point is that I don't do any gas snapshot on unit tests cuz it's just noise. There is too much irrelevant setup in those tests that will add extra gas to the gas-snapshot output and make me sad, so I prefix every unit test contract with `UnitTest` and use the `make test` command which is an alias to `forge test --match-contract "UnitTest$"`. I like to think of `optimization` as a completely separate job from `making things work`, so I don't care too much about it during this phase.

**BenchmarkTests** are tests I use in the optimization phase. I try to remove all the noise and run only a single function in the test so it returns a gas usage as close as possible from reality. Something like:

```solidity
function setUp() {
  // .. setup the enviroment for test_foo
}

function test_foo() {
  contract.foo()
}
```

Although the real gas will still be a bit far from reality, it's consistent enough for me to check if a gas optimization attempt is actually optimizing, and how much. I don't write these tests for everything, but I always do for deployment and public functions. I don't care much about admin/owner functions because they are small with not much going on. I can't justify wasting time on them.

Optimization is the last thin I do, and both unit and benchmark tests are essential for my optimization process. Once I have a baseline, I just do the following loop:

1. Change code (educated optimization guess)
2. Run `make tests`. If it breaks, revert changes - or keep changing the code until it stops breaking the tests
3. Run `make snapshot && git diff .gas-snapshot`. If it results in a better outcome, commit
4. Back to 1

**E2E** in this project is a single test that goes through happy path and some bumps. It duplicates a lot of the unit-tests but without a clean-state on every test.

It's missing fuzz tests. :(

### CI

I setup CI early in the project so it picks up some issues during development and I don't need to worry about running a bunch of tools on every commit. I'm using GitHub actions and it just runs the UnitTests + E2ETests and the solhint linter. The only thing missing was running slither, I think I got stuck for some reason and had no patience to finish setting it up (now I figured it out and was able to set it up for other projs). Also, it's cool to have those green badges in the readme.

### 3rd party

Third party tools and contracts this project uses

**Support Contracts**

- **[ds-test](https://github.com/dapphub/ds-test)** for testing
- **[forge-std](https://github.com/brockelmore/forge-std)** for HEVM interface and some type-safe evm errors
- **[openzeppelin-contracts](https://github.com/openZeppelin/openzeppelin-contracts)** for some of the contracts like verifying MerkleProof and Ownable
- **[solmate](https://github.com/Rari-Capital/solmate)** for ERC1155

**Tooling**

- **[foundry](https://github.com/gakonst/foundry)'s `forge`** for building, testing, and gas snapshots
- **[solhint](https://github.com/protofire/solhint)** for linting
- **[slither](https://github.com/crytic/slither)** for static analysis and linting
- **[solcery](https://github.com/alephao/solcery)** for code-generating type-safe errors for tests
- **[errorsig](scripts/errorsig.py)** for code-generating error signature comments

## Codegen

The [Errors.sol](src/test/utils/Errors.sol) is generated using **[solcery](https://github.com/alephao/solcery)**, it finds the custom error declaration in files and generates that. Some times I think that's overkill, but every time I add a custom error, I run `make codegen` and the error becomes instantly available in `Errors.myNewlyCreatedError()`, then I thank my younger self for setting this up.

The **[errorsig](scripts/errorsig.py)** script generate a comment on top of a custom error declaration with the error's signature e.g.:

```solidity
/// @dev 0x2c5211c6
error InvalidAmount();

```

It generates the `/// @dev 0x2c5211c6` part. Some times I think this is also overkill, but it helps me in two ways.

The first is when a test expects a function to revert with error A, but it reverts with error C. _At the time of writing this readme_, forge's output is something like `0x1234 != 0x4321`, which doesn't help in figuring out what is wrong. With those comments I can just copy/paste the hex signature in the IDE's search bar and figure out what is happening with that test. Again, this is a small detail that help in the every day development and make me less stressed.

The second has to do with the development of the interface that will interact with the contract. For this project I generated a json like this:

```json
{
  "0x12345678": {
    "name": "Foo",
    "message": "Some message the user will see when the tx errors out in the interface"
  },
  "0x2c5211c6": {
    "name": "InvalidAmount",
    "message": "You're trying to claim an invalid amount bla bla bla..."
  }
}
```

This json is used in the web UI to show users messages that makes sense, giving them a better experience when an error happen.

## Deployment

This is a cool part IMO. I deployed this contract multiple times in testnet, and made the deploy as easy as it can be.

First iteration was the [deploy.sh](scripts/deploy.sh), which wasn't great. I don't like `forge deploy`, it's confusing and I can't configure options like gas priority fee. For this version I also had to generate the merkle root with some script and then manually copy/paste into the terminal (I used a different merkle tree for testing locally/testnet).

Second iteration was the [deploy.js](scripts/deploy.js) which is a simple js script file that generates the merkle root and uses ethers.js to deploy. I could easily edit `allowlist.json` or just use a different file to see the results. It also prints stuff in the screen the way I want and let me change tx options. I'm pretty happy with the result. :D

Here is what you have to do if you want to deploy this contract:

To deploy to any evm-compatible network, you need to setup the environment variables:

```bash
cp .env.example .env
```

Then open `.env` and update the values.

| Variable Name | Description                                                                           |
| ------------- | ------------------------------------------------------------------------------------- |
| RPC_URL       | The RPC url for connecting with the chain, for example, an alchemy or infura node url |
| PRIVATE_KEY   | The private key of the wallet that will be deploying the contract                     |
| PAYOUT        | The address that will receive the ether when the `withdraw()` function is used        |
| URI           | The ERC1155 url, e.g.: `ipfs://<CID>/{id}`                                            |

Once the `.env` is set up, run `make deploy`.

## Final words

If you found this helpful or interesting, please let me know by sending me a message on twitter [@alephao\_](https://twitter.com/alephao_).
