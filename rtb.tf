resource "aws_internet_gateway" "igw-1" {
  vpc_id = "${aws_vpc.vpc-1.id}"
  tags = {
    Name = "${var.environment-tag}"
  }
}

resource "aws_route_table" "rtb-1" {
  vpc_id = "${aws_vpc.vpc-1.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw-1.id}"
  }
  tags =  {
    Name = "${var.environment-tag}"
  }
}

resource "aws_route_table_association" "rtb-1-subnet-1-assoc" {
  subnet_id      = "${aws_subnet.subnet-1.id}"
  route_table_id = "${aws_route_table.rtb-1.id}"
}

resource "aws_route_table_association" "rtb-1-subnet-2-assoc" {
  subnet_id      = "${aws_subnet.subnet-2.id}"
  route_table_id = "${aws_route_table.rtb-1.id}"
}
