variable "region" {
  default     = "eu-west-2"
  description = "AWS region"
}

variable "aws_cred_profile_name" {
  default = "default"
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
  default = "erez-worker_group_mgmt_one"
}

variable "worker_group_one_name" {
  default = "erez-worker-group-1"
}

variable "worker_group_mgmt_two_name" {
  default = "erez-worker_group_mgmt_two"
}

variable "worker_group_two_name" {
  default = "erez-worker-group-2"
}

variable "worker_group_one_instance_type" {
  default = "t2.medium"
}

variable "worker_group_two_instance_type" {
  default = "t2.small"
}

variable "worker_groups_volume_type" {
  default = "gp2"
}

variable "worker_groups_volume_size" {
  default = 10
}

variable "worker_groups_monitoring_status" {
  default = false
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
  default = "erez-k8s-vpc"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "enable_nat_gateway" {
  default = true
}

variable "single_nat_gateway" {
  default = true
}

variable "enable_dns_hostnames" {
  default = true
}

variable "subnet_tag_one" {
  default = "shared"
}

variable "subnet_tag_two" {
  default = "1"
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

variable "cluster_endpoint_private_access" {
  default = true
}

variable "argocd_name" {
  default = "argocd"
}

variable "argocd_folder_name" {
  default = "argo-cd"
}

variable "argocd_create_namespace" {
  default = true
}

variable "argocd_cleanup_on_fail" {
  default = true
}

variable "argocd_wait_on_install" {
  default = true
}