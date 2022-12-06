web3 1> /dev/null || echo "You must install GoChain Web3 to run this script: https://github.com/gochain/web3"
docker stop gochain 1> /dev/null && docker rm gochain 1> /dev/null
echo "Starting node..."
export WEB3_PRIVATE_KEY=$(web3 start 2> /dev/null | awk '$1 ~ /^(0x.+$)/ {print $0}')
export WEB3_NETWORK=localhost
while ! web3 id 2> /dev/null; do
    echo "Awaiting node connection..."
    sleep 3
done
echo "Deploying contract..."
export CONTRACT_ADDRESS=$(web3 contract deploy Contract.bin | awk 'FNR==2{print $4}')
echo "Solving for a slice size of $1..."
web3 contract call --address $CONTRACT_ADDRESS --abi Contract.abi --function solve $(cat input.txt) $1