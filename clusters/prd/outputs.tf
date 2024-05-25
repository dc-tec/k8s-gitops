output "talos_config" {
  value     = data.talos_client_configuration.main.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = data.talos_cluster_kubeconfig.main.kubeconfig_raw
  sensitive = true
}

output "control_nodes" {
  value = join(",", [for node in var.control_nodes : node.ip_address])
}

output "worker_nodes" {
  value = join(",", [for node in var.worker_nodes : node.ip_address])
}
