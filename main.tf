terraform {
  backend "s3" {
    bucket = "erez-eks-bucket"
    key    = "terraform.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_cred_profile_name
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_availability_zones" "available" {
}

resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = var.worker_group_mgmt_one_name
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = var.security_group_ssh_port
    to_port   = var.security_group_ssh_port
    protocol  = var.security_group_ssh_protocol

    cidr_blocks = [
      var.worker_group_mgmt_cidr,
    ]
  }
}

resource "aws_security_group" "worker_group_mgmt_two" {
  name_prefix = var.worker_group_mgmt_two_name
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = var.security_group_ssh_port
    to_port   = var.security_group_ssh_port
    protocol  = var.security_group_ssh_protocol

    cidr_blocks = [
      var.worker_group_mgmt_cidr,
    ]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name                 = var.vpc_name
  cidr                 = var.vpc_cidr
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = [var.vpc_private_subnet_one, var.vpc_private_subnet_two]
  public_subnets       = [var.vpc_public_subnet_one,  var.vpc_public_subnet_two]
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  enable_dns_hostnames = var.enable_dns_hostnames

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}"   = var.subnet_tag_one
    "kubernetes.io/role/elb"                      = var.subnet_tag_two
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}"   = var.subnet_tag_one
    "kubernetes.io/role/internal-elb"             = var.subnet_tag_two
  }
}

module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  cluster_name                    = var.cluster_name
  cluster_version                 = var.eks_cluster_version
  subnets                         = module.vpc.private_subnets
  cluster_create_timeout          = var.eks_cluster_timeout
  cluster_endpoint_private_access = var.cluster_endpoint_private_access 

  vpc_id = module.vpc.vpc_id

  worker_groups = [
    {
      name                          = var.worker_group_one_name
      instance_type                 = var.worker_group_one_instance_type
      asg_desired_capacity          = var.worker_group_one_nodes_num
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      root_volume_size              = var.worker_groups_volume_size
      root_volume_type              = var.worker_groups_volume_type
      enable_monitoring             = var.worker_groups_monitoring_status
    },
    {
      name                          = var.worker_group_two_name
      instance_type                 = var.worker_group_two_instance_type
      asg_desired_capacity          = var.worker_group_two_nodes_num
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      root_volume_size              = var.worker_groups_volume_size
      root_volume_type              = var.worker_groups_volume_type
      enable_monitoring             = var.worker_groups_monitoring_status
    }
  ]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

resource "helm_release" "argocd" {
  name             = var.argocd_name
  namespace        = var.argocd_name
  create_namespace = var.argocd_create_namespace
  chart            = "${path.module}/${var.argocd_folder_name}"
  wait             = var.argocd_wait_on_install
  cleanup_on_fail  = var.argocd_cleanup_on_fail
}