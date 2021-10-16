
output "eks_cluster" {
  value = aws_eks_cluster.eks_panel_cluster
}

output "endpoint" {
  value = aws_eks_cluster.eks_panel_cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks_panel_cluster.certificate_authority.0.data 
}

output "eks_token" {
  value = aws_eks_cluster.eks_panel_cluster.id
}

output "eks_identity" {
  value = aws_eks_cluster.eks_panel_cluster.identity[0].oidc[0].issuer
}

output "eks_arn" {
  value = aws_eks_cluster.eks_panel_cluster.arn
}