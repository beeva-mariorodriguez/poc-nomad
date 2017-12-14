#!/bin/bash
consulimage=${1:-"consul:1.0.0"}

docker pull "$consulimage"

docker run -d --name=consul \
    -v consul:/consul/data \
    --net=host \
    --restart=always \
    "$consulimage" \
    agent \
    -retry-join 'provider=aws tag_key=consul tag_value=poc-nomad-consul' \
    -bind '{{ GetInterfaceIP "eth0" }}' \
    -server \
    -client '{{ GetInterfaceIP "eth0" }} 127.0.0.1 172.17.0.1' \
    -bootstrap-expect 3

