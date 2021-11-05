
resource "kubernetes_config_map" "cassandra_config" {
  metadata {
    name = "cassandra-config"
  }

  binary_data = {
    "cassandra.yaml" = filebase64("${path.module}/cassandra.yaml")
  }
}