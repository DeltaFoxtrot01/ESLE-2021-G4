

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
      load = "cassandra-pods"
    }

    port {
      name = "cassandra-port1"
      port = 9042
      target_port = 9042
      protocol = "TCP"
    }
    port {
      name = "cassandra-port2"
      port = 9160
      target_port = 9160
      protocol = "TCP"
    }    

    port {
      name = "cassandra-port3"
      port = 7001
      target_port = 7001
      protocol = "TCP"
    }
    
    port {
      name = "cassandra-port4"
      port = 7199
      target_port = 7199
      protocol = "TCP"
    }


    port {
      name = "cassandra-port5"
      port = 7000
      target_port = 7000
      protocol = "TCP"
    }

    port {
      name = "http"
      port = 80
      target_port = 80
      protocol = "TCP"
    }

  }

  depends_on = [
    kubernetes_pod.cassandra
  ]
}