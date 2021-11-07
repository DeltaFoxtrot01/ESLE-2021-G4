locals {
  number_of_pods = 6
}

resource "kubernetes_pod" "cassandra" {
  count = local.number_of_pods
  metadata {
      name = "cassandra-pod-${count.index}"
      labels = {
        app = "cassandra-pod-${count.index}"
        load = "cassandra-pods"
      }
  }

  spec {

    init_container {
      name = "init-cassandra"
      image = "busybox:latest"
      command = ["sh", "-c","cp /options/cassandra/cassandra.yaml /etc/cassandra/cassandra.yaml"]

      volume_mount {
        name = "cassandra-config-temp"
        mount_path = "/options/cassandra"
      }

      volume_mount {
        name = "config-file-holder"
        mount_path = "/etc/cassandra"
      } 

    }
    container {
        #image = "yeasy/simple-web:latest"
        image = "cassandra:4.0.1"
        name = "cassandra"

        env {
          name  = "CASSANDRA_BROADCAST_ADDRESS"
          value = "cassandra-service-${count.index}.default"
        }

        env {
          name  = "CASSANDRA_SEEDS"
          value = join(",", formatlist("cassandra-service-%s.default", 
                        [for x in range(4): x if x != count.index]
                      ))
        }

        volume_mount {
          name = "config-file-holder"
          mount_path = "/etc/cassandra/cassandra.yaml"
          sub_path = "cassandra.yaml"
        } 

        port {
          container_port = 80
          protocol = "TCP"
        }

        port {
          container_port = 9042
          protocol = "TCP"
        }
        port {
          container_port = 9160
          protocol = "TCP"
        }

        port {
          container_port = 7000
          protocol = "TCP"
        }

        port {
          container_port = 7001
          protocol = "TCP"
        }
        
        port {
          container_port = 7199
          protocol = "TCP"
        }
    }

    volume {
      name = "cassandra-config-temp"
      config_map {
        name = kubernetes_config_map.cassandra_config.metadata[0].name
      }
    }

    volume {
      name = "config-file-holder"
      empty_dir {
        
      }
    }
  }
  depends_on = [
    kubernetes_service.cassandra_service
  ]
}


resource "kubernetes_service" "cassandra_service" {
  count = local.number_of_pods

  metadata {
    name = "cassandra-service-${count.index}"
    labels = {
      app = "cassandra-services"
    }
  }

  spec {
    selector = {
      app = "cassandra-pod-${count.index}"
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
      name = "cassandra-port5"
      port = 7000
      target_port = 7000
    }

    port {
      name = "http"
      port = 80
      target_port = 80
    }

  }
}

