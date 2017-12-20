# vault

https://www.vaultproject.io/
https://www.nomadproject.io/docs/vault-integration/index.html

## configure vault (manual steps!)

1. initialize vault
    1. login to any vault server
        ```bash
        ssh core@$(terraform output -json 'vault_server_public_ip' | jq -r '.value[0]')
        ```
    2. run ``docker exec vault vault init``
    3. store the keys and the initial root token

2. unseal servers, using any 3 of the 5 previously obtained unseal keys 
    in each vault server:
    ```bash
    docker exec vault vault unseal UNSEAL_KEY1
    docker exec vault vault unseal UNSEAL_KEY2
    docker exec vault vault unseal UNSEAL_KEY3
    docker exec vault vault status
    ```


3. configure vault
    1. tunnel to vault API
        ```bash
        cd nomad-aws
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

4. configure nomad servers (just the servers)
    1. create a new configuration file: /etc/nomad.d/vault.hcl:
        ```hcl
        vault {
            enabled = true
            address = "http://vault.nomad.beevalabs:8200"
            create_from_role = "nomad-cluster"
            tls_skip_verify = true
            token = "PREVIOUSLY OBTAINED TOKEN"
        }
        ```

    2. restart servers:
        ```bash
        sudo systemctl restart nomad
        ```
    

