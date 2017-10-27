resource "aws_security_group" "allowssh" {
  name   = "allowssh"
  vpc_id = "${aws_vpc.nomad.id}"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }
}

resource "aws_security_group" "consul" {
  name   = "consul"
  vpc_id = "${aws_vpc.nomad.id}"

  ingress {
    from_port = 8301
    to_port   = 8302
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 8301
    to_port   = 8302
    protocol  = "udp"
    self      = true
  }
}

resource "aws_security_group" "nomad" {
  name   = "nomad"
  vpc_id = "${aws_vpc.nomad.id}"

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
}

resource "aws_security_group" "bastion" {
  name   = "bastion"
  vpc_id = "${aws_vpc.nomad.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
