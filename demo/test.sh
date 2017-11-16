#!/bin/sh
exec ./test.py "http://$(terraform output -state ../nomad-aws/terraform.tfstate lb_dns_name)/hello"
