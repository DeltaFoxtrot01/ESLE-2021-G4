output "cluster_role" {
  value = aws_iam_role.eks-cluster-role
  description = "Role given to the cluster"
}

output "node_role" {
  value = aws_iam_role.eks-cluster-node-group-role
  description = "Role given to the node"
}

output "policies" {
  value = [aws_iam_role_policy_attachment.eks-cluster-role-AmazonEKSWorkerNodePolicy,
           aws_iam_role_policy_attachment.eks-cluster-role-AmazonEKS_CNI_Policy,
           aws_iam_role_policy_attachment.eks-cluster-role-AmazonEC2ContainerRegistry
           ]
}

output "lb_role" {
  value = aws_iam_role.iam_lb_policy
}