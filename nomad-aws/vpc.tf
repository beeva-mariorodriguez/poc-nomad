resource "aws_vpc" "nomad" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_subnet" "consul" {
  vpc_id                  = "${aws_vpc.nomad.id}"
  cidr_block              = "10.20.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "nomad" {
  vpc_id                  = "${aws_vpc.nomad.id}"
  cidr_block              = "10.20.2.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "client" {
  vpc_id                  = "${aws_vpc.nomad.id}"
  cidr_block              = "10.20.3.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "bastion" {
  vpc_id                  = "${aws_vpc.nomad.id}"
  cidr_block              = "10.20.5.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.nomad.id}"
}

resource "aws_route" "r" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = "${aws_vpc.nomad.default_route_table_id}"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

resource "null_resource" "vpc" {
  depends_on = ["aws_vpc.nomad", "aws_route.r", "aws_internet_gateway.gw", "aws_route53_zone.private"]
}
