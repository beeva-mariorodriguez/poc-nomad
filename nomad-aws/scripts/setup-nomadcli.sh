#!/bin/bash
nomadversion=${1:-"0.7.0"}
cd /tmp
wget "https://releases.hashicorp.com/nomad/${nomadversion}/nomad_${nomadversion}_linux_amd64.zip"
unzip nomad_${nomadversion}_linux_amd64.zip
sudo mkdir -p /opt/bin /etc/nomad.d /var/lib/nomad
sudo cp nomad /opt/bin

