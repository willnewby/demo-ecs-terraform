
resource "aws_security_group" "hello_ecs" {
  name        = "hello-ecs-sg"
  description = "Hello ECS SecGroup"
  vpc_id = "${aws_vpc.vpc.id}"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = ["${aws_security_group.alb_sg.id}"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


data "template_file" "ecs_init" {
  template = "${file("ecs_install.tpl")}"

  vars {
    cluster = "testecs"
  }
}

resource "aws_launch_configuration" "as_conf" {
  name_prefix   = "hello-ecs-launchconf-"
  image_id      = "${var.cluster_instance_ami}"
  instance_type = "${var.cluster_instance_type}"
  key_name      = "${var.aws_key_name}"
  security_groups = ["${aws_security_group.hello_ecs.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.ecs_instance_profile.id}"
  user_data = "${data.template_file.ecs_init.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "hello-ecs-asg" {
  name                 = "hello-ecs-asg"
  launch_configuration = "${aws_launch_configuration.as_conf.name}"
  min_size             = "${var.cluster_instance_min}"
  max_size             = "${var.cluster_instance_max}"
  desired_capacity     = "${var.cluster_instance_desired}"

  availability_zones    = "${split(",", var.availability-zones)}"
  vpc_zone_identifier   = ["${aws_subnet.public.*.id}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_cluster" "task_cluster" {
    name = "hello-ecs-cluster"
}
