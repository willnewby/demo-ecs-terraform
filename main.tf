
provider "aws" {
  region = "${var.aws_region}"
}

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
