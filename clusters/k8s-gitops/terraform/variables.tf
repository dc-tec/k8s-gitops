variable "cluster_domain" {
  description = "The domain kubernetes cluster domain name"
  type        = string
}

variable "cluster_network_name" {
  description = "The name of the network for the kubernetes cluster"
  type        = string
}

variable "cluster_network" {
  description = "The network address for the kubernetes cluster"
  type        = string
}
