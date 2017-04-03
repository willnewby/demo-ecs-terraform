
provider "aws" {}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags {
    Name = "${var.vpc}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "${var.vpc}-internet-gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags {
    Name = "${var.vpc}-public"
  }
}

resource "aws_main_route_table_association" "main" {
  vpc_id = "${aws_vpc.vpc.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_subnet" "public" {
  count = "${length(split(",", var.availability-zones))}"
  availability_zone = "${element(split(",", var.availability-zones), count.index)}"
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.2${count.index}.0/24"
  map_public_ip_on_launch = true
  tags {
    Name = "${var.vpc}-${element(split(",", var.availability-zones), count.index)}"
  }
}


resource "aws_security_group" "hello_ecs" {
  name        = "hello-ecs-sg"
  description = "Hello ECS SecGroup"
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




#TODO: create security group - DONE
#TODO: create ECS cluster, associate it with my instance
#TODO: create ECS app on this cluster
#TODO: create ELB
# User data template that specifies how to bootstrap each instance
#data "template_file" "user_data" {
#  template = "${file("${path.module}/user-data.tpl")}"

#  vars {
#    cluster_name = "${var.cluster_name}"
#  }
#}


#data "aws_ami" "ecs_ami" {
#  most_recent      = true
#  executable_users = ["self"]

#  filter {
#    name   = "owner-alias"
#    values = ["amazon"]
#  }

#  filter {
#    name   = "name"
#    values = ["amzn-ami-2016.09.g-amazon-ecs-optimize*"]
#  }
#}





data "template_file" "ecs_init" {
  template = "${file("ecs_install.tpl")}"

  vars {
    cluster = "testecs"
  }
}

resource "aws_launch_configuration" "as_conf" {
  name_prefix   = "hello-ecs-launchconf-"
  image_id      = "ami-275ffe31"
  instance_type = "t2.nano"
  key_name      = "magellan"
  security_groups = ["${aws_security_group.hello_ecs.id}"]
  iam_instance_profile = "ecsInstanceRole"
  user_data = "${data.template_file.ecs_init.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "hello-ecs-asg" {
  name                 = "hello-ecs-asg"
  launch_configuration = "${aws_launch_configuration.as_conf.name}"
  min_size             = 1
  max_size             = 8
  desired_capacity     = 3

  availability_zones    = "${split(",", var.availability-zones)}"
  vpc_zone_identifier   = ["${aws_subnet.public.*.id}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_cluster" "fuck" {
    name = "hello-ecs-cluster"
}
