#!/bin/bash

# Cosmos Gaia Node Monitoring Script

DATA_DIR="/var/lib/gaia"

while true; do
    clear
    echo "=========================================="
    echo "       Cosmos Hub Node Monitor"
    echo "=========================================="
    echo ""
    
    # Check if node is running
    if ! systemctl is-active --quiet gaiad; then
        echo "WARNING: Gaia node is not running!"
        sleep 5
        continue
    fi
    
    echo "Status: Running"
    echo ""
    
    # Get node status
    STATUS=$(gaiad status --home ${DATA_DIR} 2>&1)
    
    if [ $? -eq 0 ]; then
        # Parse status
        NETWORK=$(echo $STATUS | jq -r '.NodeInfo.network')
        MONIKER=$(echo $STATUS | jq -r '.NodeInfo.moniker')
        LATEST_HEIGHT=$(echo $STATUS | jq -r '.SyncInfo.latest_block_height')
        LATEST_TIME=$(echo $STATUS | jq -r '.SyncInfo.latest_block_time')
        CATCHING_UP=$(echo $STATUS | jq -r '.SyncInfo.catching_up')
        VOTING_POWER=$(echo $STATUS | jq -r '.ValidatorInfo.VotingPower')
        
        echo "NODE INFO"
        echo "---------"
        echo "Moniker: ${MONIKER}"
        echo "Network: ${NETWORK}"
        echo ""
        
        echo "SYNC STATUS"
        echo "-----------"
        echo "Latest Block: ${LATEST_HEIGHT}"
        echo "Block Time: ${LATEST_TIME}"
        echo "Catching Up: ${CATCHING_UP}"
        echo ""
        
        if [ "${VOTING_POWER}" != "0" ]; then
            echo "VALIDATOR INFO"
            echo "--------------"
            echo "Voting Power: ${VOTING_POWER}"
            echo ""
        fi
    else
        echo "Unable to get node status. Node may still be starting."
    fi
    
    # Peer info
    echo "NETWORK"
    echo "-------"
    PEERS=$(curl -s localhost:26657/net_info 2>/dev/null | jq -r '.result.n_peers')
    echo "Connected Peers: ${PEERS:-N/A}"
    echo ""
    
    # System Resources
    echo "SYSTEM RESOURCES"
    echo "----------------"
    
    GAIA_PID=$(pgrep -x gaiad)
    if [ -n "$GAIA_PID" ]; then
        ps -p $GAIA_PID -o %cpu,%mem,rss --no-headers | while read cpu mem rss; do
            echo "CPU: ${cpu}%"
            echo "Memory: ${mem}%"
            echo "RSS: $((rss/1024)) MB"
        done
    fi
    
    echo ""
    echo "STORAGE"
    echo "-------"
    du -sh ${DATA_DIR}/data 2>/dev/null | awk '{print "Data: " $1}'
    df -h ${DATA_DIR} | tail -1 | awk '{print "Disk Free: " $4}'
    
    echo ""
    echo "Last updated: $(date)"
    echo "Press Ctrl+C to exit"
    
    sleep 30
done
