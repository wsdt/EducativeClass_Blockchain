
const ethers = require("ethers")

const res = ethers.utils.solidityPack([], []) // ethers.utils.solidityPack(["uint16", "uint256"], [1, 225000])
console.log("Result: ", res)