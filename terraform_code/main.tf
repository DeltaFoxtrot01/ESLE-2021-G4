variable "aws_access_key" {
  description = "AWS access key"
}

variable "aws_secret_key" {
  description = "AWS secret key"
}

variable "aws_region" {
  description = "AWS region"
}

variable "cluster_name" {
  description = "name of the kubernetes cluster"
}

variable "tag" {
  description = "Regular tag for resources"
}

variable "ssh_key" {
  description = "SSH key to be used"
}

provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

module "network" {
  source = "./network"
  region = var.aws_region
  num_subnets = 3

  tag = var.tag
}

module "iam" {
  source = "./iam"

  tag = var.tag
  assume_role_policy = module.eks_cluster_panel.assume_role_policy
}


module "security_groups" {
  source = "./security_groups"

  vpc_id = module.network.vpc.id
  tag = var.tag
}


module "eks_cluster_panel" {
  source = "./eks-cluster-panel"

  cluster_name = var.cluster_name

  public_subnets = [for subnet in module.network.public_subnets : subnet.id]
  cluster_role = module.iam.cluster_role
  node_role = module.iam.node_role
  tag = var.tag  
}

module "eks_cluster_private_large_nodes" {
  source = "./eks-node-groups"
  cluster_name = var.cluster_name
  cluster = module.eks_cluster_panel.eks_cluster

  public_subnets = [for subnet in module.network.public_subnets : subnet.id]
  security_group = module.security_groups.ssh_group

  node_role = module.iam.node_role
  dependency = module.iam
  
  tag = var.tag
  ssh_key = var.ssh_key
}

data "aws_eks_cluster_auth" "eks_token" {
  name = var.cluster_name
}

provider "kubernetes" {
  host = module.eks_cluster_panel.endpoint
  token = data.aws_eks_cluster_auth.eks_token.token
  cluster_ca_certificate = base64decode(module.eks_cluster_panel.kubeconfig-certificate-authority-data)
}

provider "helm" {
  kubernetes {
    host = module.eks_cluster_panel.endpoint
    token = data.aws_eks_cluster_auth.eks_token.token
    cluster_ca_certificate = base64decode(module.eks_cluster_panel.kubeconfig-certificate-authority-data)
  }
}

module "k8_service_account" {
  source = "./k8_service_account"
  aws_lb_policy = module.iam.lb_role
  depends_on = [
    module.eks_cluster_panel
  ]
}

module "helm_packages" {
  source = "./helm_packages"
  cluster_name = var.cluster_name
  service_account_name = module.k8_service_account.service_account_name
  region = var.aws_region
  vpcId = module.network.vpc.id

  depends_on = [
    module.eks_cluster_panel
  ]
}

module "k8_objects" {
  source = "./k8_objects"

  depends_on = [
    module.eks_cluster_private_large_nodes,
    module.helm_packages,
    module.k8_service_account,
    module.eks_cluster_panel
  ]

}
