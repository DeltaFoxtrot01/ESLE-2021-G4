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

resource "helm_release" "vl-controller" {
  name = "aws-ebs-csi-driver"
  chart = "aws-ebs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  namespace = "kube-system"

  set {
    name = "clusterName"
    value = var.cluster_name
  }

  set {
    name = "controller.serviceAccount.create"
    value = "false"
  }

  set {
    name = "controller.serviceAccount.name"
    value = var.service_account_name
  }

  set {
    name = "image.repository"
    #this is region dependent -> https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
    value = "602401143452.dkr.ecr.eu-west-1.amazonaws.com/eks/aws-ebs-csi-driver"
  }
}
