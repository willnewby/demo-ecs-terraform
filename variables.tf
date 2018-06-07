
## General AWS Variables
variable "vpc" {
  description = "the vpc name"
  default = "hello-ecs"
}

variable "aws_region" {
  description = "AWS Region (i.e. us-east-1 or us-west-2)"
  default = "us-east-1"
}

variable "aws_key_name" {
    description = "key_name of an SSH key that you've already created in AWS"
}

variable "availability-zones" {
  description = "The availability-zones to create"
  default = "us-east-1a,us-east-1b,us-east-1d,us-east-1e"
}

## ECS Cluster Variables
variable "cluster_instance_type" {
    description = "AWS instance type (e.g. t2.nano, etc)"
    default = "t2.nano"
}

variable "cluster_instance_ami" {
    description = "AWS AMI used for ECS cluster machines (e.g. ami-275ffe31)"
    default = "ami-275ffe31"
}

variable "cluster_instance_min" {
    description = "The minimum number of EC2 instances to power our ECS cluster"
    default = 1
}

variable "cluster_instance_max" {
    description = "The maximum number of EC2 instances to power our ECS cluster"
    default = 5
}

variable "cluster_instance_desired" {
    description = "The desired number of EC2 instances to power our ECS cluster"
    default = 3
}


## ECS Task/Service Variables
variable "container_count" {
    description = "The number of containers/processes we want to kick off"
    default = 6
}

variable "container_source" {
    description = "Container path on dockerhub (e.g. training/webapp)"
    default = "training/webapp"
}

variable "container_port" {
    description = "Port that the service *inside* the container(s) listens on"
    default = 5000
}
