# instances
resource "aws_instance" "vault_server" {
  ami           = "${data.aws_ami.coreos.image_id}"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.consul.id}"
  key_name      = "${var.keyname}"
  count         = 2

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

  iam_instance_profile = "${aws_iam_instance_profile.vaultserver.name}"

  provisioner "file" {
    source      = "scripts/setup-vm.sh"
    destination = "/tmp/setup-vm.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "export CONSULVERSION=${var.consulversion}",
      "export CONSULKEY=${var.consulkey}",
      "export VAULTVERSION=${var.vaultversion}",
      "chmod +x /tmp/setup-vm.sh",
      "/tmp/setup-vm.sh vaultserver",
    ]
  }

  connection {
    type = "ssh"
    user = "core"
  }
}

# DNS
resource "aws_route53_record" "vault" {
  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "vault"
  type    = "A"

  alias {
    name                   = "${aws_elb.vault.dns_name}"
    zone_id                = "${aws_elb.vault.zone_id}"
    evaluate_target_health = false
  }
}

# security group
resource "aws_security_group" "vault" {
  name   = "vault"
  vpc_id = "${aws_vpc.nomad.id}"

  ingress {
    from_port       = 8200
    to_port         = 8200
    protocol        = "tcp"
    security_groups = ["${aws_security_group.nomad.id}", "${aws_security_group.bastion.id}", "${aws_security_group.vault_lb.id}"]
  }

  ingress {
    from_port = 8201
    to_port   = 8201
    protocol  = "tcp"
    self      = true
  }
}

# security group
resource "aws_security_group" "vault_lb" {
  name   = "vault_lb"
  vpc_id = "${aws_vpc.nomad.id}"

  ingress {
    from_port       = 8200
    to_port         = 8200
    protocol        = "tcp"
    security_groups = ["${aws_security_group.nomad.id}", "${aws_security_group.bastion.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.nomad.cidr_block}"]
  }
}

# IAM configuration
data "aws_iam_policy_document" "vaultserver" {
  statement {
    actions = [
      "ec2:DescribeInstances",
      "iam:GetInstanceProfile",
      "iam:GetUser",
      "iam:GetRole",
    ]

    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_instance_profile" "vaultserver" {
  name = "vaultserver"
  role = "${aws_iam_role.vaultserver.name}"
}

resource "aws_iam_role" "vaultserver" {
  name               = "vaultserver"
  assume_role_policy = "${data.aws_iam_policy_document.assumerole.json}"
}

resource "aws_iam_role_policy" "vaultserver" {
  name   = "vaultserver"
  role   = "${aws_iam_role.vaultserver.id}"
  policy = "${data.aws_iam_policy_document.vaultserver.json}"
}

# vault LB
resource "aws_elb" "vault" {
  name            = "vault"
  security_groups = ["${aws_security_group.vault_lb.id}"]
  instances       = ["${aws_instance.vault_server.*.id}"]
  subnets         = ["${aws_subnet.consul.id}"]
  internal        = true

  listener {
    instance_port     = 8200
    instance_protocol = "http"
    lb_port           = 8200
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTP:8200/v1/sys/health"
    interval            = 30
  }
}
