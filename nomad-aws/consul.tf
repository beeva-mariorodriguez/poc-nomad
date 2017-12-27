resource "aws_instance" "consul_server" {
  ami           = "${data.aws_ami.coreos.image_id}"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.consul.id}"
  key_name      = "${var.keyname}"
  count         = 3

  depends_on = [
    "null_resource.vpc",
    "aws_iam_instance_profile.consulagent",
    "aws_iam_role.consulagent",
    "aws_iam_role_policy.consulagent",
  ]

  vpc_security_group_ids = [
    "${aws_security_group.allow_outbound.id}",
    "${aws_security_group.allow_ssh.id}",
    "${aws_security_group.consul.id}",
  ]

  tags {
    consul = "poc-nomad-consul"
    Name   = "consul server"
  }

  iam_instance_profile = "${aws_iam_instance_profile.consulagent.name}"

  provisioner "file" {
    source      = "scripts/setup-vm.sh"
    destination = "/tmp/setup-vm.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "export CONSULVERSION=${var.consulversion}",
      "export CONSULKEY=${var.consulkey}",
      "chmod +x /tmp/setup-vm.sh",
      "/tmp/setup-vm.sh consulserver",
    ]
  }

  connection {
    type = "ssh"
    user = "core"
  }
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
    from_port       = 8500
    to_port         = 8500
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }
}

resource "aws_iam_instance_profile" "consulagent" {
  name = "consulagent"
  role = "${aws_iam_role.consulagent.name}"
}

resource "aws_iam_role" "consulagent" {
  name               = "consulagent"
  assume_role_policy = "${data.aws_iam_policy_document.assumerole.json}"
}

resource "aws_iam_role_policy" "consulagent" {
  name   = "consulagent"
  role   = "${aws_iam_role.consulagent.id}"
  policy = "${data.aws_iam_policy_document.describeinstances.json}"
}

resource "null_resource" "consul_cluster" {
  depends_on = ["aws_instance.consul_server", "aws_route53_record.consul"]
}
