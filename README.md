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
* python

## deploy cluster
1. build images
    ```bash
    cd nomad-aws/ami
    for f in *.json
    do
    packer build $f
    done
    ```
2. deploy cluster
    ```bash
    cd nomad-aws/
    terraform plan
    terraform deploy
    ```
3. deploy fabiolb
    ```bash
    cd nomad-aws
    ssh -L 4646:server.nomad.beevalabs:4646 $(terraform output bastion_public_ip) # tunnel to nomad API
    ```
    ```bash
    cd nomad-aws
    nomad plan jobs/fabiolb.nomad
    nomad run jobs/fabiolb.nomad
    ```

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

