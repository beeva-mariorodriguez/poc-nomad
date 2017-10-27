resource "aws_route53_zone" "private" {
  name          = "nomad.beevalabs"
  force_destroy = true
  vpc_id        = "${aws_vpc.nomad.id}"
}

resource "aws_route53_record" "consul" {
  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "consul"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.consul_server.*.private_ip}"]
}

resource "aws_route53_record" "nomad" {
  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "nomad"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.nomad_server.*.private_ip}"]
}

resource "aws_route53_record" "lb" {
  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "lb"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.fabiolb.*.private_ip}"]
}
