#!/bin/bash

# State Sync Configuration Script
# Enables fast synchronization using state sync

set -e

DATA_DIR="/var/lib/gaia"
CONFIG_FILE="${DATA_DIR}/config/config.toml"

# State sync RPC servers (use trusted providers)
SNAP_RPC1="https://cosmos-rpc.polkachu.com:443"
SNAP_RPC2="https://rpc-cosmoshub.blockapsis.com:443"

echo "Configuring State Sync..."

# Stop the node if running
sudo systemctl stop gaiad 2>/dev/null || true

# Get latest block info
LATEST_HEIGHT=$(curl -s ${SNAP_RPC1}/block | jq -r .result.block.header.height)
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000))
TRUST_HASH=$(curl -s "${SNAP_RPC1}/block?height=${BLOCK_HEIGHT}" | jq -r .result.block_id.hash)

echo "Latest Height: ${LATEST_HEIGHT}"
echo "Trust Height: ${BLOCK_HEIGHT}"
echo "Trust Hash: ${TRUST_HASH}"

# Backup existing data
if [ -d "${DATA_DIR}/data" ]; then
    echo "Backing up existing data..."
    sudo mv ${DATA_DIR}/data ${DATA_DIR}/data.backup.$(date +%Y%m%d)
fi

# Reset the node
sudo -u gaia gaiad tendermint unsafe-reset-all --home ${DATA_DIR} --keep-addr-book

# Configure state sync
sudo sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true|" ${CONFIG_FILE}
sudo sed -i.bak -E "s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"${SNAP_RPC1},${SNAP_RPC2}\"|" ${CONFIG_FILE}
sudo sed -i.bak -E "s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1${BLOCK_HEIGHT}|" ${CONFIG_FILE}
sudo sed -i.bak -E "s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"${TRUST_HASH}\"|" ${CONFIG_FILE}
sudo sed -i.bak -E "s|^(trust_period[[:space:]]+=[[:space:]]+).*$|\1\"168h0m0s\"|" ${CONFIG_FILE}

echo ""
echo "State sync configured!"
echo ""
echo "Start the node with: sudo systemctl start gaiad"
echo "Monitor with: sudo journalctl -u gaiad -f"
