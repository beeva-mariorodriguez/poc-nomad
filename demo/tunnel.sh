#!/bin/bash
exec ssh -D 12345 -L 127.0.0.1:4646:server.nomad.beevalabs:4646 "admin@$(terraform output -state ../nomad-aws/terraform.tfstate bastion_public_ip)"

