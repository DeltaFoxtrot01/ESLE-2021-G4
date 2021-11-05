variable "cluster_name" {
  description = "Name given to a cluster"
  type = string
}

variable "public_subnets" {
  type = list(string)
  description = "ids of the public subnets"
}

variable "cluster_role" {
  description = "Role for the cluster"
}

variable "node_role" {
  description = "Role for the worker nodes"
}

variable tag {
  type = string
}