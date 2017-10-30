resource "aws_elb" "lb" {
  name            = "lb"
  security_groups = ["${aws_security_group.lb.id}"]
  instances       = ["${aws_instance.nomad_docker_client.*.id}"]
  subnets         = ["${aws_subnet.client.id}"]

  listener {
    instance_port     = 9999
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTP:9998/health"
    interval            = 30
  }
}
