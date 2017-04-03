

#resource "aws_ecs_service" "mongo" {
#  name            = "mongodb"
#  cluster         = "${aws_ecs_cluster.fuck.id}"
#  task_definition = "${aws_ecs_task_definition.mongo.arn}"
#  desired_count   = 3
#  iam_role        = "${aws_iam_role.foo.arn}"
#  depends_on      = ["aws_iam_role_policy.foo"]

#  placement_strategy {
#    type  = "binpack"
#    field = "cpu"
#  }

#  load_balancer {
#    elb_name       = "${aws_elb.foo.name}"
#    container_name = "mongo"
#    container_port = 8080
#  }

#  placement_constraints {
#    type       = "memberOf"
#    expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
#  }
#}

resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "ALB SG for Hello ECS Project"
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "hello_ecs" {
  name            = "helloecs"
  internal        = false
  security_groups = ["${aws_security_group.alb_sg.id}"]
  subnets         = ["${aws_subnet.public.*.id}"]
  enable_deletion_protection = false
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.hello_ecs.id}"
  port = "80"
  protocol = "HTTP"
  default_action {
    target_group_arn = "${aws_alb_target_group.hello_ecs.id}"
    type = "forward"
  }
}

resource "aws_ecs_task_definition" "hello_ecs" {
  family = "hello-ecs-family"
  container_definitions = "${file("task_definitions/hello_ecs.json")}"
}

resource "aws_alb_target_group" "hello_ecs" {
  name     = "hello-ecs-alb-tg"
  port     = 9090
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.vpc.id}"

}

resource "aws_ecs_service" "hello_ecs" {
  name = "hello_ecs"
  cluster = "${aws_ecs_cluster.fuck.id}"
  task_definition = "${aws_ecs_task_definition.hello_ecs.arn}"
  desired_count = 5
  iam_role        = "${aws_iam_role.ecs_role.arn}"
  depends_on      = ["aws_iam_role.ecs_role"]



  load_balancer {
    target_group_arn = "${aws_alb_target_group.hello_ecs.arn}"
    container_name = "webapp"
    container_port = 5000
  }
}
