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
  }

  provisioner "remote-exec" {
    inline = [
      "docker run --name=consul --net=host -d --restart=always consul:1.0.0 agent -server -retry-join 'provider=aws tag_key=consul tag_value=poc-nomad-consul' -advertise ${self.private_ip} -bind ${self.private_ip} -bootstrap-expect 3",
    ]
  }

  connection {
    type = "ssh"
    user = "core"
  }

  iam_instance_profile = "${aws_iam_instance_profile.consulagent.name}"
}
