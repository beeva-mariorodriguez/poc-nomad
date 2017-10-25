output "consul_server_public_ip" {
  value = ["${aws_instance.consul_server.*.public_ip}"]
}

output "nomad_server_public_ip" {
  value = ["${aws_instance.nomad_server.*.public_ip}"]
}

output "nomad_docker_client_public_ip" {
  value = ["${aws_instance.nomad_docker_client.*.public_ip}"]
}

output "fabiolb_public_ip" {
  value = ["${aws_instance.fabiolb.*.public_ip}"]
}
