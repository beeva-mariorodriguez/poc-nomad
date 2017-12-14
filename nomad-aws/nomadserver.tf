data "aws_ami" "beevalabs-poc-nomad-nomadserver" {
  most_recent = true

  filter {
    name   = "owner-id"
    values = ["602636675831"]
  }

  filter {
    name   = "name"
    values = ["beevalabs-poc-nomad-nomadserver-0.7.0-*"]
  }
}

resource "aws_instance" "nomad_server" {
  ami           = "${data.aws_ami.beevalabs-poc-nomad-nomadserver.image_id}"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.nomad.id}"
  key_name      = "${var.keyname}"
  count         = 3

  vpc_security_group_ids = [
    "${aws_security_group.allow_outbound.id}",
    "${aws_security_group.consul.id}",
    "${aws_security_group.nomad.id}",
    "${aws_security_group.vault_client.id}",
  ]

  tags {
    Name = "Nomad server"
  }

  iam_instance_profile = "${aws_iam_instance_profile.consulagent.name}"
}

resource "aws_route53_record" "server" {
  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "server"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.nomad_server.*.private_ip}"]
}

resource "aws_security_group" "nomad" {
  name   = "nomad"
  vpc_id = "${aws_vpc.nomad.id}"

  ingress {
    from_port       = 4646
    to_port         = 4646
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }

  ingress {
    from_port = 4647
    to_port   = 4648
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 4647
    to_port   = 4648
    protocol  = "udp"
    self      = true
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }
}
