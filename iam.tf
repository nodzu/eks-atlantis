# OIDC and IAM

data "aws_caller_identity" "current" {}

resource "aws_iam_openid_connect_provider" "eks-openid-provider-1" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = []
  url             = "${aws_eks_cluster.eks-cluster-1.identity.0.oidc.0.issuer}"
}

# Role

resource "aws_iam_role" "eks-ops-admin-role" {
  name        = "${var.eks-ops-admin-role}"
  description = "Admin role for AWS EKS operations"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "eks.amazonaws.com",
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}

EOF
  tags = {
    Name = "${var.environment-tag}"
  }
}

data "aws_iam_policy_document" "eks-openid-policy-object" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks-openid-provider-1.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = ["${aws_iam_openid_connect_provider.eks-openid-provider-1.arn}"]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eks-admin-role" {
  assume_role_policy = "${data.aws_iam_policy_document.eks-openid-policy-object.json}"
  name               = "${var.eks-admin-role}"
}

resource "aws_iam_role" "eks-read-only-role" {
  assume_role_policy = "${data.aws_iam_policy_document.eks-openid-policy-object.json}"
  name               = "${var.eks-read-only-role}"
}

# Role Policy Attachment - ops-admin

resource "aws_iam_role_policy_attachment" "amaxon-eks-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-ops-admin-role.name
}

resource "aws_iam_role_policy_attachment" "amazon-eks-service-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks-ops-admin-role.name
}

resource "aws_iam_role_policy_attachment" "amazon-eks-worker-node-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-ops-admin-role.name
}

resource "aws_iam_role_policy_attachment" "amazon-eks-cni-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-ops-admin-role.name
}

resource "aws_iam_role_policy_attachment" "amazon-ec2-container-registry-read-only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-ops-admin-role.name
}

# Role configmap

resource "kubernetes_config_map" "rbac-iam-admin-config-map" {
  metadata {
    name      = "${var.eks-admin-config-map}"
    namespace = "kube-system"
  }

  data = {
    mapRoles = <<ROLES
- rolearn: ${aws_iam_role.eks-admin-role.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:masters
    - system:bootstrappers
    - system:nodes
ROLES
  }
}

resource "kubernetes_config_map" "rbac-iam-read-only-config-map" {
  metadata {
    name      = "${var.eks-read-only-config-map}"
    namespace = "kube-system"
  }

  data = { 
    mapRoles = <<ROLES
- rolearn: ${aws_iam_role.eks-read-only-role.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:basic-user
    - system:discovery
ROLES
  }
}
