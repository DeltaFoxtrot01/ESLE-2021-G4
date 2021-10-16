locals {
  account_name = "aws-load-balancer-controller"
}

resource "kubernetes_service_account" "lb-account" {
  metadata {
    labels = {
        "app.kubernetes.io/component":"controller",
        "app.kubernetes.io/name" : local.account_name
    }
    name = local.account_name
    namespace = "kube-system"
    annotations = {
        "eks.amazonaws.com/role-arn": var.aws_lb_policy.arn
    }
  }
}

