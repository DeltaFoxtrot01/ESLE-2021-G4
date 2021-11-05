

resource "aws_eks_node_group" "basic_node_group" {
  cluster_name = var.cluster_name
  node_group_name = "${var.cluster_name}-public-small-nodes"
  node_role_arn = var.node_role.arn
  subnet_ids = [var.public_subnets[0]]

  instance_types = ["c4.2xlarge"]

  scaling_config {
    desired_size = 6
    max_size = 6
    min_size = 6
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
