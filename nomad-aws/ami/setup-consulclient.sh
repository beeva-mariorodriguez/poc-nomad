#!/bin/bash
consulimage=${1:-"consul:1.0.0"}

docker pull "$consulimage"

docker create --name=consul \
    -v consul:/consul/data \
    --net=host \
    --restart=always \
    -e 'CONSUL_ALLOW_PRIVILEGED_PORTS=' \
    "$consulimage" \
    agent \
    -retry-join 'provider=aws tag_key=consul tag_value=poc-nomad-consul' \
    -bind '{{ GetInterfaceIP "eth0" }}' \
    -client '{{ GetInterfaceIP "eth0" }} 172.17.0.1 127.0.0.1'

