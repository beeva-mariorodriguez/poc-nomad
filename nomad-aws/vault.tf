resource "aws_instance" "vault_server" {
  ami           = "${data.aws_ami.coreos.image_id}"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.consul.id}"
  key_name      = "${var.keyname}"
  count         = 1

  vpc_security_group_ids = [
    "${aws_security_group.allow_outbound.id}",
    "${aws_security_group.allow_ssh.id}",
    "${aws_security_group.consul.id}",
    "${aws_security_group.vault.id}",
  ]

  tags {
    consul = "poc-nomad-vault"
    Name   = "vault server"
  }

  iam_instance_profile = "${aws_iam_instance_profile.consulagent.name}"

  provisioner "file" {
    source      = "scripts/setup-vaultserver.sh"
    destination = "/tmp/setup-vaultserver.sh"
  }

  provisioner "file" {
    source      = "scripts/setup-consulclient.sh"
    destination = "/tmp/setup-consulclient.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup-*.sh",
      "/tmp/setup-consulclient.sh ${var.consulimage} ${var.consulkey}",
      "/tmp/setup-vaultserver.sh ${var.vaultimage}",
    ]
  }

  connection {
    type = "ssh"
    user = "core"
  }
}

resource "aws_route53_record" "vault" {
  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "vault"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.vault_server.*.private_ip}"]
}

resource "aws_security_group" "vault" {
  name   = "vault"
  vpc_id = "${aws_vpc.nomad.id}"

  ingress {
    from_port       = 8200
    to_port         = 8200
    protocol        = "tcp"
    security_groups = ["${aws_security_group.nomad.id}", "${aws_security_group.bastion.id}"]
  }

  ingress {
    from_port       = 8201
    to_port         = 8201
    protocol        = "tcp"
    security_groups = ["${aws_security_group.nomad.id}", "${aws_security_group.bastion.id}"]
  }
}
