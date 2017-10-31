#!/bin/bash
nomadversion=${1:-"0.6.3"}
cd /tmp
wget "https://releases.hashicorp.com/nomad/${nomadversion}/nomad_${nomadversion}_linux_amd64.zip"
unzip nomad_${nomadversion}_linux_amd64.zip
sudo mkdir -p /opt/bin /etc/nomad.d /var/lib/nomad
sudo cp nomad /opt/bin

cat << EOF | sudo tee /etc/nomad.d/server.hcl
data_dir = "/var/lib/nomad"
disable_update_check = true
server {
    enabled = true
    bootstrap_expect = 3
}
EOF

cat << EOF | sudo tee /etc/systemd/system/nomad.service
[Unit]
Description=nomad server
After=network-online.target
Requires=network-online.target

[Service]
TimeoutStartSec=0
ExecStart=/opt/bin/nomad agent -config /etc/nomad.d/server.hcl

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable nomad

