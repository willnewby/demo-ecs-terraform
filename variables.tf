variable "vpc" {
  description = "the vpc name"
  default = "hello-ecs"
}

variable "availability-zones" {
  description = "The availability-zones to create"
  default = "us-east-1a,us-east-1b,us-east-1d,us-east-1e"
}
