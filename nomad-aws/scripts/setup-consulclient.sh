#!/bin/bash
consulimage=${1:-"consul:1.0.0"}
key=${2}

sudo mkdir /etc/consul.d
echo "{\"encrypt\":\"${key}\"}"  | sudo tee /etc/consul.d/encrypt.json > /dev/null

docker pull "$consulimage"

docker run -d --name=consul \
    -v consul:/consul/data \
    --net=host \
    --restart=always \
    -e 'CONSUL_ALLOW_PRIVILEGED_PORTS=' \
    "$consulimage" \
    agent \
    -config-dir /consul/config \
    -retry-join 'provider=aws tag_key=consul tag_value=poc-nomad-consul' \
    -bind '{{ GetInterfaceIP "eth0" }}' \
    -client '{{ GetInterfaceIP "eth0" }} 172.17.0.1 127.0.0.1'

sudo rm /etc/consul.d/encrypt.json

