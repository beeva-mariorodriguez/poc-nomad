data "aws_ami" "beevalabs-poc-nomad-consulserver" {
  most_recent = true

  filter {
    name   = "owner-id"
    values = ["602636675831"]
  }

  filter {
    name   = "name"
    values = ["beevalabs-poc-nomad-consulserver-1.0.0-*"]
  }
}

resource "aws_instance" "consul_server" {
  ami           = "${data.aws_ami.beevalabs-poc-nomad-consulserver.image_id}"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.consul.id}"
  key_name      = "${var.keyname}"
  count         = 3

  vpc_security_group_ids = [
    "${aws_security_group.allow_outbound.id}",
    "${aws_security_group.consul.id}",
    "${aws_security_group.vault_client.id}",
  ]

  tags {
    consul = "poc-nomad-consul"
    Name   = "consul server"
  }

  iam_instance_profile = "${aws_iam_instance_profile.consulagent.name}"
}

resource "aws_route53_record" "consul" {
  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "consul"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.consul_server.*.private_ip}"]
}

resource "aws_security_group" "consul" {
  name   = "consul"
  vpc_id = "${aws_vpc.nomad.id}"

  ingress {
    from_port = 8300
    to_port   = 8302
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 8300
    to_port   = 8302
    protocol  = "udp"
    self      = true
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }

  ingress {
    from_port       = 8500
    to_port         = 8500
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }
}
