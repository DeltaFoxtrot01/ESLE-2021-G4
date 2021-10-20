

resource "kubernetes_service" "load_balancer" {

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
      app = "cassandra-services"
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

    port {
      name = "cassandra-port3"
      port = 7001
      target_port = 7001
    }
    
    port {
      name = "cassandra-port4"
      port = 7199
      target_port = 7199
    }

    port {
      name = "http"
      port = 80
      target_port = 80
    }

  }
}