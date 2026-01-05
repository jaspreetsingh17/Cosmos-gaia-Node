#!/bin/bash

# Start Cosmos Gaia Node

set -e

DATA_DIR="/var/lib/gaia"

echo "Starting Gaia Node..."

# Start via systemd
sudo systemctl start gaiad

# Wait for startup
sleep 10

# Check if running
if systemctl is-active --quiet gaiad; then
    echo "Gaia node started successfully"
    echo ""
    
    # Check status
    echo "Node Status:"
    gaiad status --home ${DATA_DIR} 2>&1 | jq '.' || echo "Node still initializing..."
    
else
    echo "Failed to start Gaia node"
    sudo journalctl -u gaiad --no-pager -n 50
    exit 1
fi
