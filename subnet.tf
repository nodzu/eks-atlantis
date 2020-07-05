resource "aws_subnet" "subnet-1" {
  vpc_id = "${aws_vpc.vpc-1.id}"
  cidr_block = "${var.cidr-subnet-1}"
  map_public_ip_on_launch = "true"
  availability_zone = "${var.availability-zone-1}"
  tags = {
    Name = "${var.environment-tag}"
    "kubernetes.io/cluster/${var.eks-cluster-1}" = "shared"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "subnet-2" {
  vpc_id = "${aws_vpc.vpc-1.id}"
  cidr_block = "${var.cidr-subnet-2}"
  map_public_ip_on_launch = "true"
  availability_zone = "${var.availability-zone-2}"
  tags = {
    Name = "${var.environment-tag}"
    "kubernetes.io/cluster/${var.eks-cluster-1}" = "shared"
    "kubernetes.io/role/elb" = "1"
  }
}
