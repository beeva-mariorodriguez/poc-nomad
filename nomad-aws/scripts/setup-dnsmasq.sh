#!/bin/bash
image=${1:-"andyshinn/dnsmasq:2.78"}

docker pull "$image"

docker run -d --name=dnsmasq \
    --net=host \
    --restart=always \
    --cap-add NET_ADMIN \
    "$image" \
    -S /service.consul/127.0.0.1#8600 --log-facility=- -za 172.17.0.1

