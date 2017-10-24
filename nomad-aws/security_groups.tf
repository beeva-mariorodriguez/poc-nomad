resource "aws_security_group" "allowssh" {
  name   = "allowssh"
  vpc_id = "${aws_vpc.nomad.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# resource "aws_security_group" "allowoutbound" {
#   name   = "allowoutbound"
#   vpc_id = "${aws_vpc.nomad.id}"
#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = -1
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

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
