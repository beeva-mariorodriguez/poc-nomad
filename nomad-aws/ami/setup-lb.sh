#!/bin/bash
lbimage=${1:-"fabiolb/fabio:1.5.2-go1.9.1"}

docker pull "$lbimage"

docker create --name=fabio \
    --net=host \
    --restart=always \
    "$lbimage"

