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

resource "aws_route53_record" "server" {
  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "server"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.nomad_server.*.private_ip}"]
}

resource "aws_route53_record" "client" {
  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "client"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.nomad_docker_client.*.private_ip}"]
}

