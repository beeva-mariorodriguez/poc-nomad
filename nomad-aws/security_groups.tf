resource "aws_security_group" "allow_outbound" {
  name   = "allow_outbound"
  vpc_id = "${aws_vpc.nomad.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
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

resource "aws_security_group" "lb" {
  name   = "lb"
  vpc_id = "${aws_vpc.nomad.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
