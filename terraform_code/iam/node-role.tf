/**
  Role for the node groups
*/

resource "aws_iam_role" "eks-cluster-node-group-role" {
  name = "eks-cluster-group-role-tf"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  }) 
}

resource "aws_iam_role_policy_attachment" "eks-cluster-role-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.eks-cluster-node-group-role.name  
}

resource "aws_iam_role_policy_attachment" "eks-cluster-role-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.eks-cluster-node-group-role.name  
}

resource "aws_iam_role_policy_attachment" "eks-cluster-role-AmazonEC2ContainerRegistry" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role = aws_iam_role.eks-cluster-node-group-role.name  
}