#!/bin/bash
consulimage=${1:-"consul:1.0.0"}
nomadimage=${1:-"beevamariorodriguez/nomad:v0.6.3"}

docker pull "$consulimage"
docker pull "$nomadimage"

docker create --name=consul \
    -v consul:/consul/data \
    --net=host \
    --restart=always \
    "$consulimage" \
    agent \
    -retry-join 'provider=aws tag_key=consul tag_value=poc-nomad-consul' \
    -bind '{{ GetInterfaceIP "eth0" }}'

docker create --name=nomad \
    --net=host \
    --restart=always \
    -v nomad:/nomad/data \
    "$nomadimage" \
    agent \
    -config=/nomad/config/server.hcl

