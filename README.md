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
0. ``cd nomad-aws``
1. deploy bastion
    ```bash
    terraform plan -target aws_instance.bastion
    terraform apply -target aws_instance.bastion
    ```
2. deploy consul cluster
    ```bash
    terraform plan -target null_resource.consul_cluster
    terraform apply -target null_resource.consul_cluster
    ```
2. deploy vault cluster
    ```bash
    terraform plan -target null_resource.vault_cluster
    terraform apply -target null_resource.vault_cluster
    ```
3. initialize vault
    ```bash
    ssh core@$(terraform output -json vault_server_public_ip | jq -r '.value[0]') docker exec vault vault init -key-shares=1 -key-threshold=1
    ```
    store the unseal key and initial root token
4. unseal vault servers using the unseal key obtained in step 3
    ```bash
    for h in $(terraform output -json vault_server_public_ip | jq -r '.value[]')
    do
        ssh core@$h docker exec vault vault unseal $UNSEAL_KEY
    done
    ```
5. configure vault
    1. tunnel to vault API
        ```bash
        ssh -L 8200:vault.nomad.beevalabs:8200 core@$(terraform output bastion_public_ip)
        ```
    2. apply the example configuration (https://www.nomadproject.io/docs/vault-integration/index.html)
        ```bash
        export VAULT_ADDR=http://127.0.0.1:8200
        vault auth VAULT_INITIAL_ROOT_TOKEN
        # write the policy
        vault policy-write nomad-server vault/nomad-server-policy.hcl
        # create a cluster role based on this policy
        vault write /auth/token/roles/nomad-cluster @vault/nomad-cluster-role.json
        # create a token to be used by nomad!
        vault token-create -policy nomad-server -period 72h -orphan
        ```
6. deploy nomad cluster
    ```bash
    terraform plan -var 'nomad_vault_token=NOMAD_TOKEN' -target null_resource.nomad_cluster
    terraform apply -var 'nomad_vault_token=NOMAD_TOKEN' -target null_resource.nomad_cluster
    ```
7. deploy fabiolb
    ```bash
    ssh -L 4646:server.nomad.beevalabs:4646 core@$(terraform output bastion_public_ip) # tunnel to nomad API
    ```
    ```bash
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

