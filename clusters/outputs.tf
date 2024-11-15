output "talos_config" {
  value     = module.talos_cluster.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = module.talos_cluster.kubeconfig
  sensitive = true
}

output "control_nodes" {
  value = module.talos_cluster.control_nodes
}

output "worker_nodes" {
  value = module.talos_cluster.worker_nodes
}
