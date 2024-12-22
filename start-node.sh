#!/bin/bash

# Directory for the chain data
DATA_DIR="./node1"

# Initialize the genesis block if data directory doesn't exist
if [ ! -d "$DATA_DIR" ]; then
    geth init --datadir $DATA_DIR genesis.json
fi

# Create password file if it doesn't exist
echo "your-password" > password.txt

# Create account if it doesn't exist
if [ ! -d "$DATA_DIR/keystore" ]; then
    geth account new --datadir $DATA_DIR --password password.txt
fi

# Start the node
geth \
    --datadir $DATA_DIR \
    --networkid 12345 \
    --mine \
    --miner.threads 1 \
    --http \
    --http.addr "0.0.0.0" \
    --http.port 8545 \
    --http.api "eth,net,web3,personal,admin,miner" \
    --http.corsdomain "*" \
    --ws \
    --ws.addr "0.0.0.0" \
    --ws.port 8546 \
    --ws.api "eth,net,web3,personal,admin,miner" \
    --ws.origins "*" \
    --allow-insecure-unlock \
    --unlock 0 \
    --password password.txt \
    --nodiscover \
    --port 30303 \
    --verbosity 3 