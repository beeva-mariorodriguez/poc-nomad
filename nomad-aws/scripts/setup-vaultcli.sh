#!/bin/bash
vaultversion=${1:-"0.9.0"}
cd /tmp
wget "https://releases.hashicorp.com/vault/${vaultversion}/vault_${vaultversion}_linux_amd64.zip"
unzip vault_${vaultversion}_linux_amd64.zip
sudo mkdir -p /opt/bin
sudo cp vault /opt/bin
