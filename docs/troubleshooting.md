# Cosmos Gaia Node Troubleshooting

## Common Issues

### Node Not Syncing

**Symptom**: Block height not increasing

**Solutions**:
1. Check peer connections
2. Verify seeds and persistent peers
3. Check network connectivity
4. Try state sync for faster initial sync

```bash
# Check sync status
gaiad status --home /var/lib/gaia | jq '.SyncInfo'

# Check peer count
curl -s localhost:26657/net_info | jq '.result.n_peers'
```

### App Hash Mismatch

**Symptom**: Node crashes with app hash error

**Solutions**:
1. This usually means consensus failure
2. Check if using correct version for current height
3. May need to resync from snapshot

```bash
# Reset and resync
gaiad tendermint unsafe-reset-all --home /var/lib/gaia --keep-addr-book
```

### Out of Memory

**Symptom**: Node killed by OOM killer

**Solutions**:
1. Increase system RAM
2. Enable pruning
3. Reduce database cache

```bash
# Check memory usage
free -h

# Check if OOM killed
dmesg | grep -i "killed process"
```

### Consensus Failure

**Symptom**: Node halts at specific height

**Solutions**:
1. Check if upgrade is required
2. Verify using correct binary version
3. Check governance proposals for upgrade height

### Too Many Open Files

**Symptom**: Node crashes with file descriptor errors

**Solutions**:
1. Increase file descriptor limits
2. Add to /etc/security/limits.conf:

```
gaia soft nofile 65535
gaia hard nofile 65535
```

### Peer Connection Issues

**Symptom**: Few or no peers connecting

**Solutions**:
1. Check firewall rules
2. Verify port 26656 is accessible
3. Update seeds and persistent peers
4. Download fresh addrbook

```bash
# Download new addrbook
wget -O /var/lib/gaia/config/addrbook.json https://snapshots.polkachu.com/addrbook/cosmos/addrbook.json
```

### Validator Jailed

**Symptom**: Validator not signing blocks

**Solutions**:
1. Check if node is running and synced
2. Verify priv_validator_key.json is correct
3. Unjail after fixing issues

```bash
# Check validator status
gaiad query staking validator $(gaiad keys show validator --bech val -a) --home /var/lib/gaia

# Unjail
gaiad tx slashing unjail --from validator --chain-id cosmoshub-4 --home /var/lib/gaia
```

## State Sync Recovery

If state sync fails:

```bash
# Reset node
gaiad tendermint unsafe-reset-all --home /var/lib/gaia

# Reconfigure state sync with new trust height
./scripts/state-sync.sh

# Restart
sudo systemctl start gaiad
```

## Snapshot Recovery

Download and restore from snapshot:

```bash
# Stop node
sudo systemctl stop gaiad

# Remove old data
rm -rf /var/lib/gaia/data

# Download snapshot
wget -O - https://snapshots.polkachu.com/snapshots/cosmos/cosmos_XXXXX.tar.lz4 | lz4 -dc - | tar -xf - -C /var/lib/gaia

# Restart
sudo systemctl start gaiad
```

## Useful Commands

```bash
# Node status
gaiad status --home /var/lib/gaia

# Query balance
gaiad query bank balances <address> --home /var/lib/gaia

# Query staking info
gaiad query staking validators --home /var/lib/gaia

# Get node ID
gaiad tendermint show-node-id --home /var/lib/gaia

# View logs
sudo journalctl -u gaiad -f

# Check version
gaiad version --long
```

## Upgrade Process

When chain upgrade is required:

1. Wait for upgrade height
2. Node will halt automatically
3. Replace binary with new version
4. Restart node

```bash
sudo systemctl stop gaiad
# Install new version
sudo systemctl start gaiad
```

## Log Locations

- Systemd logs: `journalctl -u gaiad`
- Prometheus metrics: `http://localhost:26660/metrics`
