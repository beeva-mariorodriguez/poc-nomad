data "aws_ami" "beevalabs-poc-nomad-nomadclient" {
  most_recent = true

  filter {
    name   = "owner-id"
    values = ["602636675831"]
  }

  filter {
    name   = "name"
    values = ["beevalabs-poc-nomad-nomadclient-0.7.0-*"]
  }
}

resource "aws_instance" "nomad_docker_client" {
  ami           = "${data.aws_ami.beevalabs-poc-nomad-nomadclient.image_id}"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.client.id}"
  key_name      = "${var.keyname}"
  count         = 4

  vpc_security_group_ids = [
    "${aws_security_group.allow_outbound.id}",
    "${aws_security_group.consul.id}",
    "${aws_security_group.nomad.id}",
    "${aws_security_group.nomad_client.id}",
    "${aws_security_group.vault_client.id}",
  ]

  tags {
    Name = "Nomad client"
  }

  iam_instance_profile = "${aws_iam_instance_profile.consulagent.name}"
}

resource "aws_route53_record" "client" {
  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "client"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.nomad_docker_client.*.private_ip}"]
}

resource "aws_security_group" "nomad_client" {
  name   = "nomad_client"
  vpc_id = "${aws_vpc.nomad.id}"

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port       = 9998
    to_port         = 9999
    protocol        = "tcp"
    security_groups = ["${aws_security_group.lb.id}", "${aws_security_group.bastion.id}"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }
}
