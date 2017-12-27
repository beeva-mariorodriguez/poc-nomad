# poc-nomad

https://www.nomadproject.io
https://www.nomadproject.io/intro/index.html

this repo contains:
* terraform and packer code to deploy a nomad cluster
* some example jobs

## software needed
* packer
* terraform
* nomad CLI
* vault CLI
* python

## deploy cluster
1. deploy cluster
    ```bash
    cd nomad-aws/
    terraform plan
    terraform deploy
    ```
2. deploy fabiolb
    ```bash
    cd nomad-aws
    ssh -L 4646:server.nomad.beevalabs:4646 core@$(terraform output bastion_public_ip) # tunnel to nomad API
    ```
    ```bash
    cd nomad-aws
    nomad plan jobs/fabiolb.nomad
    nomad run jobs/fabiolb.nomad
    ```
3. configure vault - follow instructions in VAULT.md

## run example service
```bash
cd nomad-aws
ssh -L 4646:server.nomad.beevalabs:4646 $(terraform output bastion_public_ip) # tunnel to nomad API
```

```bash
cd demo
nomad plan hellohttp.nomad
nomad run hellohttp.nomad
```

```bash
cd nomad-aws
../demo/test.py "http://$(terraform output lb_dns_name)/hello"
```

hellohttp has 3 tags:
* scratch: docker image built from scratch
* alpine: docker image built from alpine
* deadcanary: fails with 500 server error, nomad should not let you promote this deployment

