const { execSync } = require("child_process");
const ethers = require("ethers")
const allowlist = require("../allowlist.json")
const { MerkleTree } = require('merkletreejs')
require('dotenv').config()

const RPC_URL = process.env.RPC_URL
const PRIVATE_KEY = process.env.PRIVATE_KEY
const PAYOUT = process.env.PAYOUT
const URI =  process.env.URI

const gwei = (val) => {
  return ethers.utils.parseUnits(val, "gwei")
}

const getMerkleRoot = () => {
  const keccak256 = ethers.utils.keccak256
  const toUtf8Bytes = ethers.utils.toUtf8Bytes

  const leavesUnhashed = allowlist.map((item) => {
      return `${item.address.toLowerCase()}:${item.amount}`
  })

  const leaves = leavesUnhashed.map((x) => keccak256(toUtf8Bytes(x)))
  const tree = new MerkleTree(leaves, keccak256, { sortLeaves: true, sortPairs: true, hashLeaves: false })
  const root = tree.getHexRoot()
  console.log("ROOT", root)
  return root
}

const main = async () => {
  execSync("forge build --force --optimize")
  const TitanTiki3D = require("../out/TitanTiki3D.sol/TitanTiki3D.json")

  const provider = new ethers.providers.JsonRpcProvider(RPC_URL)
  const wallet = new ethers.Wallet(PRIVATE_KEY, provider)

  const contractFactory = new ethers.ContractFactory(TitanTiki3D.abi, TitanTiki3D.bytecode, wallet)

  const payoutAddress = PAYOUT
  const uri = URI
  const merkleRoot = getMerkleRoot()

  console.log("Payout address:", payoutAddress)
  console.log("URI:", uri)
  console.log("Merkle root:", merkleRoot)
  console.log("Sending deployment tx with arguments")

  const contract = await contractFactory.deploy(payoutAddress, uri, merkleRoot)
  console.log("Waiting for tx to be mined...")
  console.log("Tx Hash:", contract.deployTransaction.hash)
  console.log("Contract Address:", contract.address)
  await contract.deployed()
  console.log("Done!")
}

main()