output "talos_config" {
  value     = data.talos_client_configuration.main.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = talos_cluster_kubeconfig.main.kubeconfig_raw
  sensitive = true
}

output "control_nodes" {
  value = join(",", [for key in keys(var.control_nodes) : libvirt_domain.control_node[key].network_interface[0].addresses[0]])
}

output "worker_nodes" {
  value = join(",", [for key in keys(var.worker_nodes) : libvirt_domain.worker_node[key].network_interface[0].addresses[0]])
}
