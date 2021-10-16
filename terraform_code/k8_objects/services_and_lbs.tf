

resource "kubernetes_service" "load_balancer" {
  count = 1
  metadata {
    name = "main-lb"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type": "external"
      "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type": "ip"
      "service.beta.kubernetes.io/aws-load-balancer-scheme": "internet-facing"
    }
  }

  spec {
    type = "LoadBalancer"
    selector = {
        "own-pod" = "cassandra"
    }
    port {
        name = "cassandra-port1"
        port = 9042
        target_port = 9042
    }
    port {
        name = "cassandra-port2"
        port = 9160
        target_port = 9160
    }    
  }
}