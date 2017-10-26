data "aws_ami" "beevalabs-poc-nomad-consulserver" {
  most_recent = true

  filter {
    name   = "owner-id"
    values = ["602636675831"]
  }

  filter {
    name   = "name"
    values = ["beevalabs-poc-nomad-consulserver-*"]
  }
}

data "aws_ami" "beevalabs-poc-nomad-nomadserver" {
  most_recent = true

  filter {
    name   = "owner-id"
    values = ["602636675831"]
  }

  filter {
    name   = "name"
    values = ["beevalabs-poc-nomad-nomadserver-*"]
  }
}

data "aws_ami" "beevalabs-poc-nomad-nomadclient" {
  most_recent = true

  filter {
    name   = "owner-id"
    values = ["602636675831"]
  }

  filter {
    name   = "name"
    values = ["beevalabs-poc-nomad-nomadclient-*"]
  }
}

data "aws_ami" "beevalabs-poc-nomad-lb" {
  most_recent = true

  filter {
    name   = "owner-id"
    values = ["602636675831"]
  }

  filter {
    name   = "name"
    values = ["beevalabs-poc-nomad-lb-*"]
  }
}

resource "aws_instance" "consul_server" {
  ami           = "${data.aws_ami.beevalabs-poc-nomad-consulserver.image_id}"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.consul.id}"
  key_name      = "${var.keyname}"
  count         = 3

  vpc_security_group_ids = [
    "${aws_vpc.nomad.default_security_group_id}",
    "${aws_security_group.consul.id}",
    "${aws_security_group.allowssh.id}",
  ]

  tags {
    consul = "poc-nomad-consul"
    Name   = "consul server"
  }

  iam_instance_profile = "${aws_iam_instance_profile.consulagent.name}"
}

resource "aws_instance" "nomad_server" {
  ami           = "${data.aws_ami.beevalabs-poc-nomad-nomadserver.image_id}"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.nomad.id}"
  key_name      = "${var.keyname}"
  count         = 3

  vpc_security_group_ids = [
    "${aws_vpc.nomad.default_security_group_id}",
    "${aws_security_group.consul.id}",
    "${aws_security_group.nomad.id}",
    "${aws_security_group.allowssh.id}",
  ]

  tags {
    Name = "Nomad server"
  }

  iam_instance_profile = "${aws_iam_instance_profile.consulagent.name}"
}

resource "aws_instance" "nomad_docker_client" {
  ami           = "${data.aws_ami.beevalabs-poc-nomad-nomadclient.image_id}"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.client.id}"
  key_name      = "${var.keyname}"
  count         = 2

  vpc_security_group_ids = [
    "${aws_vpc.nomad.default_security_group_id}",
    "${aws_security_group.consul.id}",
    "${aws_security_group.nomad.id}",
    "${aws_security_group.nomad_client.id}",
    "${aws_security_group.allowssh.id}",
  ]

  tags {
    Name = "Nomad client"
  }

  iam_instance_profile = "${aws_iam_instance_profile.consulagent.name}"
}

resource "aws_instance" "fabiolb" {
  ami           = "${data.aws_ami.beevalabs-poc-nomad-lb.image_id}"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.lb.id}"
  key_name      = "${var.keyname}"
  count         = 1

  vpc_security_group_ids = [
    "${aws_vpc.nomad.default_security_group_id}",
    "${aws_security_group.consul.id}",
    "${aws_security_group.fabiolb.id}",
    "${aws_security_group.allowssh.id}",
  ]

  tags {
    Name = "LB"
  }

  iam_instance_profile = "${aws_iam_instance_profile.consulagent.name}"
}
