resource "aws_instance" "consul_server" {
  ami           = "${data.aws_ami.beevalabs-poc-nomad-consulserver.image_id}"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.consul.id}"
  key_name      = "${var.keyname}"
  count         = 3

  vpc_security_group_ids = [
    "${aws_security_group.allow_outbound.id}",
    "${aws_security_group.consul.id}",
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
    "${aws_security_group.allow_outbound.id}",
    "${aws_security_group.consul.id}",
    "${aws_security_group.nomad.id}",
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
  count         = 4

  vpc_security_group_ids = [
    "${aws_security_group.allow_outbound.id}",
    "${aws_security_group.consul.id}",
    "${aws_security_group.nomad.id}",
    "${aws_security_group.nomad_client.id}",
  ]

  tags {
    Name = "Nomad client"
  }

  iam_instance_profile = "${aws_iam_instance_profile.consulagent.name}"
}

resource "aws_instance" "bastion" {
  ami           = "${data.aws_ami.coreos.image_id}"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.bastion.id}"
  key_name      = "${var.keyname}"
  count         = 1

  vpc_security_group_ids = [
    "${aws_security_group.allow_outbound.id}",
    "${aws_security_group.bastion.id}",
  ]

  tags {
    Name = "bastion"
  }

  iam_instance_profile = "${aws_iam_instance_profile.consulagent.name}"

  provisioner "remote-exec" {
    inline = [
      "wget https://releases.hashicorp.com/nomad/0.7.0-rc3/nomad_0.7.0_rc3_linux_amd64.zip",
      "sudo mkdir -p /opt/bin",
      "sudo unzip nomad*.zip -d /opt/bin",
    ]
  }

  connection {
    type = "ssh"
    user = "core"
  }
}
