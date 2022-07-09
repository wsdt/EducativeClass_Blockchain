const ethers = require("ethers")

const exec = async () => {
    let privateKey = '0x0123456789012345678901234567890123456789012345678901234567890123';
    let wallet = new ethers.Wallet(privateKey);

    console.log(wallet.address);
// "0x14791697260E4c9A71f18484C9f997B308e59325"

// The hash we wish to sign and verify
    let messageHash = ethers.utils.solidityKeccak256(['address', 'uint256', 'uint256'], [0, 0, 0])

    let messageHashBytes = ethers.utils.arrayify(messageHash)

// Sign the binary data
    let flatSig = await wallet.signMessage(messageHashBytes);

// For Solidity, we need the expanded-format of a signature
    let sig = ethers.utils.splitSignature(flatSig);

    console.log("SIG: ", flatSig, sig);
}

exec().then(console.log).catch(console.error)