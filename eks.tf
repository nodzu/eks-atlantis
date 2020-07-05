resource "aws_eks_cluster" "eks-cluster-1" {
  name     = "${var.eks-cluster-1}"
  role_arn = aws_iam_role.eks-ops-admin-role.arn

  vpc_config {
    subnet_ids = [aws_subnet.subnet-1.id, aws_subnet.subnet-2.id]
    security_group_ids = [aws_security_group.eks-sg-1.id]
  }

  tags = {
    Name = "${var.environment-tag}"
  }
}

resource "aws_eks_node_group" "eks-ng-1" {
  cluster_name    = aws_eks_cluster.eks-cluster-1.name
  node_group_name = "${var.eks-ng-1}"
  node_role_arn   = aws_iam_role.eks-ops-admin-role.arn
  subnet_ids      = [aws_subnet.subnet-1.id, aws_subnet.subnet-2.id]
  instance_types  = ["${var.eks-ng-1-instance-type}"]
  disk_size       = "${var.eks-ng-1-disk-size}"
  tags = {
    Name = "${var.environment-tag}"
  }
  scaling_config {
    desired_size = "${var.eks-asg-1-desired}"
    max_size     = "${var.eks-asg-1-max}"
    min_size     = "${var.eks-asg-1-min}"
  }
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_eks_cluster.eks-cluster-1
  ]
}
