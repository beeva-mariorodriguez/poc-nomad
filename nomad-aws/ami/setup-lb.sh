#!/bin/bash
consulimage=${1:-"consul:1.0.0"}
lbimage=${1:-"fabiolb/fabio:1.5.2-go1.9.1"}

docker pull "$consulimage"
docker pull "$lbimage"

docker create --name=consul \
    -v consul:/consul/data \
    --net=host \
    --restart=always \
    "$consulimage" \
    agent \
    -retry-join 'provider=aws tag_key=consul tag_value=poc-nomad-consul' \
    -bind '{{ GetInterfaceIP "eth0" }}'

docker create --name=fabio \
    --net=host \
    --restart=always \
    "$lbimage"

