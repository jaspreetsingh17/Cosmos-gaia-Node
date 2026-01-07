# Cosmos Hub (Gaia) Node Deployment

Complete guide for deploying a Cosmos Hub full node using Gaia.

## Overview

Cosmos Hub is the first blockchain in the Cosmos ecosystem, serving as the economic center of the interchain. This repository provides configuration and scripts for running a Gaia full node or validator.

## Requirements

- Ubuntu 22.04 LTS or Debian 12
- 4 CPU cores (8 recommended for validators)
- 32GB RAM
- 500GB SSD storage (NVMe recommended)
- 100 Mbps network connection

## Architecture

```
                    +------------------+
                    |   Cosmos SDK     |
                    |   Application    |
                    +--------+---------+
                             |
                    +--------+---------+
                    |   Tendermint     |
                    |   Consensus      |
                    +--------+---------+
                             |
                        P2P Network
```

## Quick Start

```bash
git clone https://github.com/jaspreetsingh17/Cosmos-gaia-Node.git
cd cosmos-gaia-node
chmod +x scripts/install.sh
./scripts/install.sh
```

## Directory Structure

```
.
├── config/
│   ├── app.toml
│   ├── config.toml
│   └── client.toml
├── scripts/
│   ├── install.sh
│   ├── start.sh
│   ├── state-sync.sh
│   └── monitor.sh
├── docker/
│   └── docker-compose.yml
├── systemd/
│   └── gaiad.service
└── docs/
    ├── validator.md
    └── troubleshooting.md
```

## Node Types

### Full Node
- Stores complete blockchain history
- Verifies all transactions
- Serves RPC queries
- Does not participate in consensus

### Pruned Node
- Stores recent state only
- Lower disk requirements
- Suitable for RPC endpoints

### Archive Node
- Stores all historical states
- Required for historical queries
- High storage requirements

### Validator
- Participates in consensus
- Requires bonded ATOM
- Earns staking rewards

## Ports

| Port | Purpose |
|------|---------|
| 26656 | P2P |
| 26657 | RPC |
| 26658 | ABCI |
| 1317 | REST API |
| 9090 | gRPC |
| 9091 | gRPC-Web |

## Sync Options

- **Block Sync**: Download and verify all blocks (slowest)
- **State Sync**: Download recent state snapshot (fastest)
- **Snapshot**: Download pre-synced database

## License

MIT License
