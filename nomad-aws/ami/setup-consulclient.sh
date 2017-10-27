#!/bin/bash
consulimage=${1:-"consul:1.0.0"}

docker pull "$consulimage"

docker create --name=consul \
    -v consul:/consul/data \
    --net=host \
    --restart=always \
    "$consulimage" \
    agent \
    -retry-join 'provider=aws tag_key=consul tag_value=poc-nomad-consul' \
    -bind '{{ GetInterfaceIP "eth0" }}'

