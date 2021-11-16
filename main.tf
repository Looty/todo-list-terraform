provider "aws" {
  region  = var.region
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

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = var.all_workder_group_name
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = var.security_group_ssh_port
    to_port   = var.security_group_ssh_port
    protocol  = var.security_group_ssh_protocol

    cidr_blocks = [
      var.worker_group_mgmt_cidr,
      var.worker_group_mgmt_cidr_extra_one,
      var.worker_group_mgmt_cidr_extra_two,
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
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  cluster_name                    = var.cluster_name
  cluster_version                 = var.eks_cluster_version
  subnets                         = module.vpc.private_subnets
  cluster_create_timeout          = var.eks_cluster_timeout
  cluster_endpoint_private_access = true 

  vpc_id = module.vpc.vpc_id

  worker_groups = [
    {
      name                          = var.worker_group_one_name
      instance_type                 = var.worker_group_one_instance_type
      asg_desired_capacity          = var.worker_group_one_nodes_num
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },
    {
      name                          = var.worker_group_two_name
      instance_type                 = var.worker_group_two_instance_type
      asg_desired_capacity          = var.worker_group_two_nodes_num
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
    }
  ]

  worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# resource "kubernetes_deployment" "example" {
#   metadata {
#     name = "terraform-example"
#     labels = {
#       test = "MyExampleApp"
#     }
#   }

#   spec {
#     replicas = 2

#     selector {
#       match_labels = {
#         test = "MyExampleApp"
#       }
#     }

#     template {
#       metadata {
#         labels = {
#           test = "MyExampleApp"
#         }
#       }

#       spec {
#         container {
#           image = "nginx:1.7.8"
#           name  = "example"

#           resources {
#             limits = {
#               cpu    = "0.5"
#               memory = "512Mi"
#             }
#             requests = {
#               cpu    = "250m"
#               memory = "50Mi"
#             }
#           }
#         }
#       }
#     }
#   }
# }

# resource "kubernetes_service" "example" {
#   metadata {
#     name = "terraform-example"
#   }
#   spec {
#     selector = {
#       test = "MyExampleApp"
#     }
#     port {
#       port        = 80
#       target_port = 80
#     }

#     type = "LoadBalancer"
#   }
# }