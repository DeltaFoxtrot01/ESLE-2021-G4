variable region {
  #region to host the VPC
  type = string
}

variable tag {
  type = string
}

variable "num_subnets" {
  type = number
  default = 2
}