
variable "cluster_name" {
  description = "Name of the cluster"
}

variable "cluster" {
  description = "EKS cluster object"  
}

variable "public_subnets" {
  description = "required existing public subnets"
}

variable "node_role" {
  description = "Role for the node"
}

variable "dependency" {
  description = "All exisiting IAM policies"
}

variable "tag" {
  type = string
}

variable "ssh_key"{
  type = string
}

variable "security_group" {
  description = "Security group for ssh"
}