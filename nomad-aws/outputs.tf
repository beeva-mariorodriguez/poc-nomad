output "bastion_public_ip" {
  value = ["${aws_instance.bastion.*.public_ip}"]
}

output "consul_server_public_ip" {
  value = ["${aws_instance.consul_server.*.public_ip}"]
}

output "nomad_server_public_ip" {
  value = ["${aws_instance.nomad_server.*.public_ip}"]
}

output "nomad_docker_client_public_ip" {
  value = ["${aws_instance.nomad_docker_client.*.public_ip}"]
}

output "vault_server_public_ip" {
  value = ["${aws_instance.vault_server.*.public_ip}"]
}

output "lb_dns_name" {
  value = "${aws_elb.lb.dns_name}"
}
