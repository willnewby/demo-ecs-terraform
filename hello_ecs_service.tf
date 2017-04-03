
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "ALB SG for Hello ECS Project"
  vpc_id = "${aws_vpc.vpc.id}"

  ingress = [
            {
                from_port   = 80
                to_port     = 80
                protocol    = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
            },
            {
                from_port   = 443
                to_port     = 443
                protocol    = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
            }
      ]
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

data "template_file" "hello_ecs_def" {
  template = "${file("task_definitions/hello_ecs.json")}"

  vars {
    container_port = "${var.container_port}"
    container_source = "${var.container_source}"
  }
}

resource "aws_ecs_task_definition" "hello_ecs" {
  family = "hello-ecs-family"
  container_definitions = "${data.template_file.hello_ecs_def.rendered}"
}

resource "aws_alb_target_group" "hello_ecs" {
  name     = "hello-ecs-alb-tg"
  port     = 9090
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.vpc.id}"
}

resource "aws_ecs_service" "hello_ecs" {
  name = "hello_ecs"
  cluster = "${aws_ecs_cluster.task_cluster.id}"
  task_definition = "${aws_ecs_task_definition.hello_ecs.arn}"
  desired_count = "${var.container_count}"
  iam_role        = "${aws_iam_role.ecs_role.arn}"
  depends_on      = ["aws_iam_role.ecs_role", "aws_alb_listener.front_end"]

  load_balancer {
    target_group_arn = "${aws_alb_target_group.hello_ecs.arn}"
    container_name = "webapp"
    container_port = "${var.container_port}"
  }
}
