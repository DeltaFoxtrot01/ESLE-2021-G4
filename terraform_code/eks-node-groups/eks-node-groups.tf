

resource "aws_eks_node_group" "private_large_node_group" {
  cluster_name = var.cluster_name
  node_group_name = "${var.cluster_name}-private-large-nodes"
  node_role_arn = var.node_role.arn
  subnet_ids = var.private_subnets

  instance_types = ["c4.2xlarge"]

  scaling_config {
    desired_size = 4
    max_size = 5
    min_size = 1
  }

  remote_access {
    ec2_ssh_key = var.ssh_key
    source_security_group_ids = [ var.security_group.id ]
  }

  depends_on = [var.dependency, var.cluster]
  tags = {
    "kubernetes.io/cluster/esleCluster" = "owned"
  }
}

resource "aws_eks_node_group" "private_small_node_group" {
  cluster_name = var.cluster_name
  node_group_name = "${var.cluster_name}-private-small-nodes"
  node_role_arn = var.node_role.arn
  subnet_ids = var.public_subnets

  instance_types = ["c4.xlarge"]

  scaling_config {
    desired_size = 5
    max_size = 6
    min_size = 3
  }

  remote_access {
    ec2_ssh_key = var.ssh_key
    source_security_group_ids = [ var.security_group.id ]
  }

  depends_on = [var.dependency, var.cluster]
  tags = {
    "kubernetes.io/cluster/esleCluster" = "owned"
  }
}
