 # To load the variables in the .env file
 source .env

 forge create ./src/Wavect.sol:Wavect --constructor-args "https://wavect.io/official-nft/contract-metadata.json" "https://wavect.io/official-nft/logo_square.jpg" "Wavect" \
  "This NFT can be used to vote on podcast guests, topics and many other things. We also plan to release products in the near future, this NFT will give you then a lifelong rebate and gives you access to our Improve-the-World campaign." \
  "https://wavect.io?nft=true" "https://wavect.io/official-nft/wavect_video.mp4" ".jpg" 100 0x4356ad31af829c8a7305544d695feb2d676503330d33d508a300302544927853 \
  --rpc-url $RINKEBY_RPC_URL  --private-key $PRIVATE_KEY --verify --etherscan-api-key $ETHERSCAN_KEY
