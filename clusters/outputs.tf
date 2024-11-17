output "talos_config" {
  value       = module.talos_cluster.talos_config
  description = "The Talos configuration for the cluster"
  sensitive   = true
}

output "kubeconfig" {
  value       = module.talos_cluster.kubeconfig
  description = "The kubeconfig for the cluster"
  sensitive   = true
}

output "control_nodes" {
  value       = module.talos_cluster.control_nodes
  description = "The control nodes for the cluster"
}

output "worker_nodes" {
  value       = module.talos_cluster.worker_nodes
  description = "The worker nodes for the cluster"
}

output "cluster_env" {
  value       = var.cluster_env
  description = "The environment for the cluster"
}
