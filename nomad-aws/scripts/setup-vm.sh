#!/bin/bash
# setup-vm.sh bastion|consulserver|nomadserver|nomadclient|vaultserver

function nomad_cli {
    nomadversion=${NOMADVERSION:-"0.7.0"}
    cd /tmp
    wget "https://releases.hashicorp.com/nomad/${nomadversion}/nomad_${nomadversion}_linux_amd64.zip"
    unzip "nomad_${nomadversion}_linux_amd64.zip"
    sudo mkdir -p /opt/bin
    sudo cp nomad /opt/bin
}

function vault_cli {
    vaultversion=${VAULTVERSION:-"0.9.0"}
    cd /tmp
    wget "https://releases.hashicorp.com/vault/${vaultversion}/vault_${vaultversion}_linux_amd64.zip"
    unzip "vault_${vaultversion}_linux_amd64.zip"
    sudo mkdir -p /opt/bin
    sudo cp vault /opt/bin
}

function consul_cli {
    consulversion=${CONSULVERSION:-"1.0.1"}
    cd /tmp
    wget "https://releases.hashicorp.com/consul/${consulversion}/consul_${consulversion}_linux_amd64.zip"
    unzip "consul_${consulversion}_linux_amd64.zip"
    sudo mkdir -p /opt/bin
    sudo cp consul /opt/bin
}

function consul_container {
    consulversion=${CONSULVERSION:-"1.0.1"}
    consulimage="docker.io/consul:${consulversion}"

    sudo mkdir /etc/consul.d
    docker pull "$consulimage"

    if [[ "${CONSULKEY}" ]]
    then
        echo "{\"encrypt\":\"${CONSULKEY}\"}"  | sudo tee /etc/consul.d/encrypt.json
    fi
}

function consul_server {
    consul_container
    docker run -d --name=consul \
        -v consul:/consul/data \
        -v /etc/consul.d:/consul/config \
        --net=host \
        --restart=always \
        "$consulimage" \
        agent \
        -config-dir /consul/config \
        -retry-join 'provider=aws tag_key=consul tag_value=poc-nomad-consul' \
        -bind '{{ GetInterfaceIP "eth0" }}' \
        -server \
        -client '{{ GetInterfaceIP "eth0" }} 127.0.0.1 172.17.0.1' \
        -bootstrap-expect 3
}

function consul_client {
    consul_container
    docker run -d --name=consul \
        -v consul:/consul/data \
        -v /etc/consul.d:/consul/config \
        --net=host \
        --restart=always \
        -e 'CONSUL_ALLOW_PRIVILEGED_PORTS=' \
        "$consulimage" \
        agent \
        -config-dir /consul/config \
        -retry-join 'provider=aws tag_key=consul tag_value=poc-nomad-consul' \
        -bind '{{ GetInterfaceIP "eth0" }}' \
        -client '{{ GetInterfaceIP "eth0" }} 127.0.0.1 172.17.0.1'
}

function nomad_service {
    nomad_cli
    sudo mkdir -p /etc/nomad.d /var/lib/nomad
    role=${1:-"client"}

    case $role in
        "server")
            cat << EOF | sudo tee /etc/nomad.d/server.hcl
data_dir = "/var/lib/nomad"
disable_update_check = true
server {
    enabled = true
    bootstrap_expect = 3
}
EOF
            if [[ $NOMADKEY ]]
            then
                sudo sed -i "/server {/a\ \ \ \ encrypt = \"${NOMADKEY}\"" /etc/nomad.d/server.hcl
            fi
;;
        "client")
            cat << EOF | sudo tee /etc/nomad.d/client.hcl
data_dir = "/var/lib/nomad"
disable_update_check = true
client {
    enabled = true
}
EOF
;;
    esac


    cat << EOF | sudo tee /etc/systemd/system/nomad.service
[Unit]
Description=nomad $role
After=network-online.target
Requires=network-online.target

[Service]
TimeoutStartSec=0
ExecStart=/opt/bin/nomad agent -config /etc/nomad.d

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl enable "nomad"
    sudo systemctl start "nomad"
}

function nomad_client {
    nomad_service client
}

function nomad_server {
    nomad_service server
}

function vault_server {
    vaultversion=${VAULTVERSION:-"0.9.0"} 
    vaultimage="docker.io/vault:${vaultversion}"

    sudo mkdir -p /etc/vault.d
    private_ip=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
    docker pull "$vaultimage"

    cat << EOF | sudo tee /etc/vault.d/storage.hcl
storage "consul" {
    address = "127.0.0.1:8500"
}
EOF

    cat << EOF | sudo tee /etc/vault.d/listener.hcl
listener "tcp" {
    address = "${private_ip}:8200"
    tls_disable = "true"
}
EOF

    docker run -d --name=vault \
        --cap-add IPC_LOCK \
        -v /etc/vault.d:/etc/vault.d \
        --net=host \
        --restart=always \
        -e "VAULT_ADDR=http://${private_ip}:8200" \
        "$vaultimage" \
        server \
        -config '/etc/vault.d'
}

function dnsmasq {
    image=${DNSMASQIMAGE:-"andyshinn/dnsmasq:2.78"}

    docker pull "$image"

    docker run -d --name=dnsmasq \
        --net=host \
        --restart=always \
        --cap-add NET_ADMIN \
        "$image" \
        -S /service.consul/127.0.0.1#8600 --log-facility=- -za 172.17.0.1
}

case $1 in
    "bastion")
        nomad_cli
        vault_cli
        consul_cli
        ;;
    "consulserver")
        consul_server
        ;;
    "nomadserver")
        consul_client
        nomad_server
        ;;
    "nomadclient")
        consul_client
        dnsmasq
        nomad_client
        ;;
    "vaultserver")
        vault_cli
        consul_client
        vault_server
        ;;
esac

