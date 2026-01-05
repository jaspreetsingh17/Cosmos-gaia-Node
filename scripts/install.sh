#!/bin/bash

# Cosmos Gaia Node Installation Script
# Tested on Ubuntu 22.04 LTS

set -e

GAIA_VERSION="v15.1.0"
CHAIN_ID="cosmoshub-4"
DATA_DIR="/var/lib/gaia"
CONFIG_DIR="/etc/gaia"

echo "Installing Gaia ${GAIA_VERSION}..."

# Update system
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y \
    build-essential \
    git \
    curl \
    wget \
    jq \
    lz4

# Install Go
GO_VERSION="1.21.6"
wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
rm go${GO_VERSION}.linux-amd64.tar.gz

export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc

# Create gaia user
if ! id "gaia" &>/dev/null; then
    sudo useradd -r -m -s /bin/bash gaia
fi

# Build Gaia from source
cd /tmp
git clone https://github.com/cosmos/gaia.git
cd gaia
git checkout ${GAIA_VERSION}
make install

# Copy binary to system path
sudo cp ~/go/bin/gaiad /usr/local/bin/
sudo chmod +x /usr/local/bin/gaiad

# Verify installation
gaiad version

# Initialize node
sudo -u gaia gaiad init "cosmos-node" --chain-id ${CHAIN_ID} --home ${DATA_DIR}

# Download genesis file
wget -O /tmp/genesis.json https://raw.githubusercontent.com/cosmos/mainnet/master/genesis/genesis.cosmoshub-4.json.gz
gunzip -c /tmp/genesis.json > ${DATA_DIR}/config/genesis.json

# Download addrbook for faster peer discovery
wget -O ${DATA_DIR}/config/addrbook.json https://snapshots.polkachu.com/addrbook/cosmos/addrbook.json

# Copy configurations
sudo cp ../config/app.toml ${DATA_DIR}/config/app.toml
sudo cp ../config/config.toml ${DATA_DIR}/config/config.toml
sudo cp ../config/client.toml ${DATA_DIR}/config/client.toml

# Set permissions
sudo chown -R gaia:gaia ${DATA_DIR}

# Install systemd service
sudo cp ../systemd/gaiad.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable gaiad

# Configure firewall
sudo ufw allow 26656/tcp
sudo ufw allow 26657/tcp

# Cleanup
rm -rf /tmp/gaia

echo ""
echo "Installation complete!"
echo ""
echo "Data directory: ${DATA_DIR}"
echo "Chain ID: ${CHAIN_ID}"
echo ""
echo "For faster sync, run: ./scripts/state-sync.sh"
echo "Or start with: sudo systemctl start gaiad"
