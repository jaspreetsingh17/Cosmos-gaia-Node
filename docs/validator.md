# Cosmos Hub Validator Guide

## Overview

Running a Cosmos Hub validator allows you to participate in consensus and earn staking rewards. This guide covers the setup process and best practices.

## Requirements

### Hardware
- 8+ CPU cores
- 64GB RAM
- 1TB NVMe SSD
- 1 Gbps network
- Static IP address

### Financial
- Minimum self-delegation to enter active set
- ATOM for transaction fees
- Sufficient stake to be in top 180 validators

## Validator Setup

### 1. Create Validator Keys

```bash
# Create new key
gaiad keys add validator --home /var/lib/gaia

# Or recover existing key
gaiad keys add validator --recover --home /var/lib/gaia
```

### 2. Fund Your Account

Get your address:
```bash
gaiad keys show validator -a --home /var/lib/gaia
```

Transfer ATOM to this address from an exchange or another wallet.

### 3. Create Validator

Wait for node to fully sync, then:

```bash
gaiad tx staking create-validator \
    --amount=1000000uatom \
    --pubkey=$(gaiad tendermint show-validator --home /var/lib/gaia) \
    --moniker="Your Validator Name" \
    --chain-id=cosmoshub-4 \
    --commission-rate="0.10" \
    --commission-max-rate="0.20" \
    --commission-max-change-rate="0.01" \
    --min-self-delegation="1" \
    --gas="auto" \
    --gas-adjustment="1.5" \
    --gas-prices="0.0025uatom" \
    --from=validator \
    --home /var/lib/gaia
```

### 4. Confirm Registration

```bash
gaiad query staking validator $(gaiad keys show validator --bech val -a --home /var/lib/gaia) --home /var/lib/gaia
```

## Validator Operations

### Edit Validator Info

```bash
gaiad tx staking edit-validator \
    --moniker="New Name" \
    --website="https://your-website.com" \
    --identity="YOUR_KEYBASE_ID" \
    --details="Validator description" \
    --chain-id=cosmoshub-4 \
    --gas="auto" \
    --gas-prices="0.0025uatom" \
    --from=validator \
    --home /var/lib/gaia
```

### Unjail Validator

If your validator gets jailed:

```bash
gaiad tx slashing unjail \
    --from=validator \
    --chain-id=cosmoshub-4 \
    --gas="auto" \
    --gas-prices="0.0025uatom" \
    --home /var/lib/gaia
```

### Withdraw Rewards

```bash
gaiad tx distribution withdraw-rewards $(gaiad keys show validator --bech val -a --home /var/lib/gaia) \
    --commission \
    --from=validator \
    --chain-id=cosmoshub-4 \
    --gas="auto" \
    --gas-prices="0.0025uatom" \
    --home /var/lib/gaia
```

## Key Security

### Backup Validator Key

The most critical file is:
```
/var/lib/gaia/config/priv_validator_key.json
```

Back this up securely and never share it.

### Using Remote Signer

For production validators, consider using:
- Tendermint KMS with HSM
- Horcrux for distributed signing

## Slashing Conditions

| Condition | Penalty | Jail Time |
|-----------|---------|-----------|
| Double signing | 5% stake | Permanent |
| Downtime (missing 10000 of last 50000 blocks) | 0.01% stake | 10 minutes |

## Monitoring

Set up alerts for:
- Missed blocks
- Validator jailing
- Low disk space
- High memory usage
- Network connectivity issues

## High Availability

### Sentry Node Architecture

```
        Internet
            |
    +-------+-------+
    |               |
+---+---+       +---+---+
| Sentry |       | Sentry |
|  Node  |       |  Node  |
+---+---+       +---+---+
    |               |
    +-------+-------+
            |
    +-------+-------+
    |   Validator   |
    |    (Private)  |
    +---------------+
```

Configure sentry nodes as persistent peers and keep validator private.

## Best Practices

1. Never run two validators with same key
2. Keep validator private, use sentry nodes
3. Monitor continuously
4. Keep software updated
5. Have incident response plan
6. Test upgrades on testnet first
