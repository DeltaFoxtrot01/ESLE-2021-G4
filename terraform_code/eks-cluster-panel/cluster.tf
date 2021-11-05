
resource "aws_eks_cluster" "eks_panel_cluster" {
  name = var.cluster_name
  role_arn = var.cluster_role.arn
  version="1.21"

  vpc_config {
    subnet_ids = var.public_subnets
  }

  depends_on = [ 
    var.cluster_role,
    var.node_role
   ]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.eks_panel_cluster.name
  addon_name   = "vpc-cni"
}

data "tls_certificate" "tls" {
  url = aws_eks_cluster.eks_panel_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "open_id_connect_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.tls.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_panel_cluster.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.open_id_connect_provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node","system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.open_id_connect_provider.arn]
      type        = "Federated"
    }
  }
}



#these policies are placed here as they refer to cluster add ons

resource "aws_iam_role" "iam_role_vpc_cni" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  name               = "vpc-cni-role"
}

resource "aws_iam_role_policy_attachment" "cni_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.iam_role_vpc_cni.name
}

