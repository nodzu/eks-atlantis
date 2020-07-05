resource "aws_security_group" "eks-sg-1" {
  name        = "${var.security-group-1}"
  description = "Allow all internal traffic"
  vpc_id      = "${aws_vpc.vpc-1.id}"

  ingress {
    description = "All traffic from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.security-group-1}"
  }
}
