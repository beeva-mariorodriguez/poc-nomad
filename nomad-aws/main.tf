data "aws_ami" "coreos" {
  most_recent = true

  filter {
    name   = "owner-id"
    values = ["679593333241"]
  }

  filter {
    name   = "name"
    values = ["CoreOS-stable-*"]
  }
}

resource "aws_instance" "consul_server" {
  ami           = "${data.aws_ami.coreos.image_id}"
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

  provisioner "remote-exec" {
    inline = [
      "docker run -v consul:/consul/data --name=consul --net=host -d --restart=always consul:1.0.0 agent -server -retry-join 'provider=aws tag_key=consul tag_value=poc-nomad-consul' -advertise ${self.private_ip} -bind ${self.private_ip} -bootstrap-expect 3",
    ]
  }

  connection {
    type = "ssh"
    user = "core"
  }

  iam_instance_profile = "${aws_iam_instance_profile.consulagent.name}"
}

resource "aws_instance" "nomad_server" {
  ami           = "${data.aws_ami.coreos.image_id}"
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

  provisioner "remote-exec" {
    inline = [
      "docker run -v consul:/consul/data --name=consul --net=host -d --restart=always consul:1.0.0 agent -retry-join 'provider=aws tag_key=consul tag_value=poc-nomad-consul' -advertise ${self.private_ip} -bind ${self.private_ip}",
      "docker run --name=nomad --net=host -d --restart=always -v nomad:/nomad/data beevamariorodriguez/nomad:v0.6.3 agent -config=/nomad/config/server.hcl",
    ]
  }

  connection {
    type = "ssh"
    user = "core"
  }

  iam_instance_profile = "${aws_iam_instance_profile.consulagent.name}"
}

resource "aws_instance" "nomad_docker_client" {
  ami           = "${data.aws_ami.coreos.image_id}"
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

  provisioner "remote-exec" {
    inline = [
      "docker run -v consul:/consul/data --name=consul --net=host -d --restart=always consul:1.0.0 agent -retry-join 'provider=aws tag_key=consul tag_value=poc-nomad-consul' -advertise ${self.private_ip} -bind ${self.private_ip}",
      "docker run --privileged -v /tmp:/tmp -v /var/run/docker.sock:/var/run/docker.sock -v nomad:/nomad/data --name=nomad --net=host -d --restart=always beevamariorodriguez/nomad:v0.6.3",
    ]
  }

  connection {
    type = "ssh"
    user = "core"
  }

  iam_instance_profile = "${aws_iam_instance_profile.consulagent.name}"
}

resource "aws_instance" "fabiolb" {
  ami           = "${data.aws_ami.coreos.image_id}"
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
    Name = "Traefik"
  }

  provisioner "remote-exec" {
    inline = [
      "docker run -v consul:/consul/data --name=consul --net=host -d --restart=always consul:1.0.0 agent -retry-join 'provider=aws tag_key=consul tag_value=poc-nomad-consul' -advertise ${self.private_ip} -bind ${self.private_ip}",
      "docker run --name=fabio -d --restart=always --net=host fabiolb/fabio:1.5.2-go1.9.1"
    ]
  }

  connection {
    type = "ssh"
    user = "core"
  }

  iam_instance_profile = "${aws_iam_instance_profile.consulagent.name}"
}
