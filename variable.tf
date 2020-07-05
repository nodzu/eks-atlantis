variable "environment-tag" {
  description = "Environment tag"
  default = "nodzu"
}

variable "cidr-vpc-1" {
  description = "CIDR block for the VPC"
  default = "10.100.0.0/16"
}

variable "cidr-subnet-1" {
  description = "CIDR block for subnet 1"
  default = "10.100.1.0/24"
}

variable "cidr-subnet-2" {
  description = "CIDR block for subnet 2"
  default = "10.100.2.0/24"
}

variable "availability-zone-1" {
  description = "Availability zone to create subnet 1"
  default = "eu-north-1a"
}

variable "availability-zone-2" {
  description = "Availability zone to create subnet 2"
  default = "eu-north-1b"
}

variable "security-group-1" {
  description = "Security group 1 name"
  default = "nodzu-eks-sg-1"
}

variable "security-group-2" {
  description = "Security group 2 name"
  default = "nodzu-lb-sg-1"
}

variable "eks-read-only-role" {
  description = "EKS read-only role name"
  default = "eks-read-only"
}

variable "eks-admin-role" {
  description = "EKS admin role name"
  default = "eks-admin"
}

variable "eks-ops-admin-role" {
  description = "EKS admin role name"
  default = "eks-ops-admin"
}

variable "eks-admin-config-map" {
  description = "EKS admin role name"
  default = "nodzu-admin"
}

variable "eks-read-only-config-map" {
  description = "EKS admin role name"
  default = "nodzu-read-only"
}

variable "eks-service-account-admin" {
  description = "K8s admin service account"
  default = "nodzu-service-account-admin"
}

variable "eks-service-account-read-only" {
  description = "K8s read-only service account"
  default = "nodzu-service-account-read-only"
}

variable "eks-cluster-1" {
  description = "EKS cluster name"
  default = "eks-nodzu-cluster-1"
}

variable "eks-ng-1" {
  description = "EKS node group 1 name"
  default = "eks-nodzu-ng-1"
}

variable "eks-ng-1-instance-type" {
  description = "EKS node group 1 instance type"
  default = "t3.small"
}

variable "eks-ng-1-disk-size" {
  description = "EKS node group 1 disk size"
  default = "8"
}
