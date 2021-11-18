variable "region" {
  default     = "eu-central-1"
  description = "AWS region"
}

variable "cluster_name" {
  default = "erez-eks"
}

variable "security_group_ssh_port" {
  default = "22"
}

variable "security_group_ssh_protocol" {
  default = "tcp"
}

variable "worker_group_mgmt_one_name" {
  default = "worker_group_mgmt_one"
}

variable "worker_group_one_name" {
  default = "worker-group-1"
}

variable "worker_group_mgmt_two_name" {
  default = "worker_group_mgmt_two"
}

variable "worker_group_two_name" {
  default = "worker-group-2"
}

variable "worker_group_one_instance_type" {
  default = "t2.medium"
}

variable "worker_group_two_instance_type" {
  default = "t2.small"
}

variable "worker_group_one_nodes_num" {
  default = 3
}

variable "worker_group_two_nodes_num" {
  default = 3
}

variable "worker_group_mgmt_cidr" {
  default = "10.0.0.0/8"
}

variable "vpc_name" {
  default = "k8s-vpc"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "vpc_private_subnet_one" {
  default = "10.0.1.0/24"
}

variable "vpc_private_subnet_two" {
  default = "10.0.2.0/24"
}

variable "vpc_public_subnet_one" {
  default = "10.0.3.0/24"
}

variable "vpc_public_subnet_two" {
  default = "10.0.4.0/24"
}

variable "eks_cluster_version" {
  default = "1.21"
}

variable "eks_cluster_timeout" {
  default = "1h"
}

variable "argocd_name" {
  default = "argocd"
}

variable "argocd_folder_name" {
  default = "argo-cd"
}