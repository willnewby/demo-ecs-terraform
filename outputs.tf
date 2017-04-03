output "lb_address" {
  value = "${aws_alb.hello_ecs.dns_name}"
}
