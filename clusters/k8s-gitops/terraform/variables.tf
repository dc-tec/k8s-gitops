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

variable "base_volume" {
  description = "The base volume for our Talos VM's"
  type        = string
  default     = "talos"
}

variable "control_nodes" {
  description = "Control node configuration"
  type = map(object({
    node_name = string
  }))
}

variable "worker_nodes" {
  description = "Worker node configuration"
  type = map(object({
    node_name = string
  }))
}
