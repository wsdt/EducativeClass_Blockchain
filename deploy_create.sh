 # To load the variables in the .env file
 source .env

 forge create ./src/Wavect.sol:Wavect --constructor-args $RINKEBY_L0_ENDPOINT "https://wavect.io/official-nft/contract-metadata.json" \
    "https://wavect.io/official-nft/metadata/1.json?debug=" "Wavect", "WACT", ".json" 100 \
     0x4356ad31af829c8a7305544d695feb2d676503330d33d508a300302544927853 \
  --rpc-url $RINKEBY_RPC_URL  --private-key $PRIVATE_KEY --verify --etherscan-api-key $ETHERSCAN_KEY


  forge create ./src/Wavect.sol:Wavect --constructor-args $MUMBAI_L0_ENDPOINT "https://wavect.io/official-nft/contract-metadata.json" \
      "https://wavect.io/official-nft/metadata/1.json?debug=" "Wavect", "WACT", ".json" 100 \
      0x4356ad31af829c8a7305544d695feb2d676503330d33d508a300302544927853 \
    --rpc-url $MUMBAI_RPC_URL  --private-key $PRIVATE_KEY --verify --etherscan-api-key $ETHERSCAN_KEY
