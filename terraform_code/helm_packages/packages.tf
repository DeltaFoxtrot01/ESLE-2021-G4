resource "helm_release" "lb-controller" {
  name = "aws-load-balancer-controller"
  chart = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  namespace = "kube-system"

  set {
    name = "clusterName"
    value = var.cluster_name
  }

  set {
    name = "serviceAccount.create"
    value = "false"
  }

  set {
    name = "serviceAccount.name"
    value = var.service_account_name
  }

  set {
    name = "region"
    value = var.region
  }

  set {
    name = "vpcId"
    value = var.vpcId
  }

}
