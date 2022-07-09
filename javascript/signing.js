const ethers = require("ethers")

const exec = async () => {
    let privateKey = '0x0123456789012345678901234567890123456789012345678901234567890123';
    let wallet = new ethers.Wallet(privateKey);

    console.log(wallet.address);
// "0x14791697260E4c9A71f18484C9f997B308e59325"

    let message = ethers.utils.solidityPack(['address', 'uint256', 'uint256'],
        ["0x0000000000000000000000000000000000000003", 0, 0]);
    message = ethers.utils.solidityKeccak256(["bytes"], [message]);
    const signature = await wallet.signMessage(ethers.utils.arrayify(message));

// The hash we wish to sign and verify
    /*let messageHash = ethers.utils.solidityKeccak256(['address', 'uint256', 'uint256'], ["0x0000000000000000000000000000000000000002", "0", "0"])

    let messageHashBytes = ethers.utils.arrayify(messageHash)

// Sign the binary data
    let flatSig = await wallet.signMessage(messageHashBytes);

// For Solidity, we need the expanded-format of a signature -> ALSO IMPORTANT!!
    let sig = ethers.utils.splitSignature(flatSig);*/

    console.log("SIG: ", signature);
}

exec().then(console.log).catch(console.error)