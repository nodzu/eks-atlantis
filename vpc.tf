resource "aws_vpc" "vpc-1" {
  cidr_block       = "${var.cidr-vpc-1}"
  instance_tenancy = "default"

  tags = {
    "Name" = "${var.environment-tag}"
  }
}
