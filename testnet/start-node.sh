#!/bin/bash

# Get the absolute path to the go-ethereum root directory
GETH_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GETH_PATH="$GETH_ROOT/build/bin/geth"

# Check if geth binary exists
if [ ! -f "$GETH_PATH" ]; then
    echo "Error: Could not find geth binary at $GETH_PATH"
    echo "Please ensure you've built geth using 'make geth'"
    exit 1
fi

echo "Using geth binary at: $GETH_PATH"

# Directory for the chain data (absolute path)
DATA_DIR="$(pwd)/node1"
GENESIS_FILE="$(pwd)/genesis.json"
PASSWORD_FILE="$(pwd)/password.txt"

# Clean up old data if exists
rm -rf $DATA_DIR
rm -f $GENESIS_FILE
rm -f $PASSWORD_FILE

# Create password file
echo "your-password" > $PASSWORD_FILE

# Create account
echo "Creating new account..."
ACCOUNT_ADDRESS=$($GETH_PATH account new --datadir $DATA_DIR --password $PASSWORD_FILE | grep -o '0x[0-9a-fA-F]\{40\}')
if [ -z "$ACCOUNT_ADDRESS" ]; then
    echo "Failed to create account"
    exit 1
fi

VALIDATOR_ADDRESS=${ACCOUNT_ADDRESS#0x}
echo "Created account: $ACCOUNT_ADDRESS"

# Create genesis file
cat > $GENESIS_FILE << EOF
{
  "config": {
    "chainId": 12345,
    "homesteadBlock": 0,
    "eip150Block": 0,
    "eip155Block": 0,
    "eip158Block": 0,
    "byzantiumBlock": 0,
    "constantinopleBlock": 0,
    "petersburgBlock": 0,
    "istanbulBlock": 0,
    "berlinBlock": 0,
    "londonBlock": 0,
    "clique": {
      "period": 5,
      "epoch": 30000
    }
  },
  "difficulty": "1",
  "gasLimit": "8000000",
  "extradata": "0x0000000000000000000000000000000000000000000000000000000000000000${VALIDATOR_ADDRESS}0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
  "alloc": {
    "${VALIDATOR_ADDRESS}": {
      "balance": "100000000000000000000000"
    }
  }
}
EOF

# Initialize genesis block
$GETH_PATH init --datadir $DATA_DIR $GENESIS_FILE

echo "Genesis initialized with validator: $ACCOUNT_ADDRESS"

# Start the node with Clique consensus
$GETH_PATH \
    --datadir $DATA_DIR \
    --networkid 12345 \
    --http \
    --http.addr "0.0.0.0" \
    --http.port 8545 \
    --http.api "eth,net,web3,personal,admin,clique" \
    --http.corsdomain "*" \
    --ws \
    --ws.addr "0.0.0.0" \
    --ws.port 8546 \
    --ws.api "eth,net,web3,personal,admin,clique" \
    --ws.origins "*" \
    --allow-insecure-unlock \
    --unlock $ACCOUNT_ADDRESS \
    --password $PASSWORD_FILE \
    --nodiscover \
    --port 30303 \
    --verbosity 3 \
    --mine \
    --miner.etherbase $ACCOUNT_ADDRESS