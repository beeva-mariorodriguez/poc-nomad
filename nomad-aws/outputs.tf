output "bastion_public_ip" {
  value = ["${aws_instance.bastion.*.public_ip}"]
}

output "lb_dns_name" {
  value = "${aws_elb.lb.dns_name}"
}
