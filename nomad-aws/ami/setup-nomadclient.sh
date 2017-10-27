#!/bin/bash
nomadimage=${1:-"beevamariorodriguez/nomad:v0.6.3"}

docker pull "$nomadimage"

docker create --name=nomad \
    --net=host \
    --restart=always \
    -v nomad:/nomad/data \
    -v /tmp:/tmp \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --privileged \
    "$nomadimage"

