resource "aws_route53_zone" "private" {
  name          = "nomad.beevalabs"
  force_destroy = true
  vpc_id        = "${aws_vpc.nomad.id}"
}
