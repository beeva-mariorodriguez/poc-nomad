#!/bin/bash
nomadimage=${1:-"beevamariorodriguez/nomad:v0.6.3"}

docker pull "$nomadimage"

docker create --name=nomad \
    --net=host \
    --restart=always \
    -v nomad:/nomad/data \
    "$nomadimage" \
    agent \
    -config=/nomad/config/server.hcl

