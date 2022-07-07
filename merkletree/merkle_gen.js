const {MerkleTree} = require("merkletreejs")
const keccak256 = require("keccak256")

// List of 7 public Ethereum addresses
let addresses = ["0x0000000000000000000000000000000000000001", "0x0000000000000000000000000000000000000002", "0x0000000000000000000000000000000000000003", "0x0000000000000000000000000000000000000004"]

// Hash leaves
let leaves = addresses.map(addr => keccak256(addr))

// Create tree
let merkleTree = new MerkleTree(leaves, keccak256, {sortPairs: true})
let rootHash = merkleTree.getRoot().toString('hex')

// Pretty-print tree
console.log(merkleTree.toString())
console.log(rootHash)


for (const address of addresses) {
    let hashedAddress = keccak256(address)
    let proof = merkleTree.getHexProof(hashedAddress)
    console.log(proof)
    let proofBytes = merkleTree.getProof(hashedAddress)
    console.log(proofBytes)

    let v = merkleTree.verify(proof, hashedAddress, rootHash)
    console.log(v) // returns true
}