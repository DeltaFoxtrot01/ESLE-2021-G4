


resource "kubernetes_pod" "name" {

  metadata {
      name = "cassandra-pod"
      labels = {
        "own-pod" = "cassandra"
      }
  }

  spec {
    container {
        image = "cassandra:latest"
        name = "cassandra"
    
        port {
          container_port = 9042
          protocol = "TCP"
        }
        port {
          container_port = 9160
          protocol = "TCP"
        }
    }

    
  }
}