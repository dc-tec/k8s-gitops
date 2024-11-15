# Generic cluster information
cluster_env    = "tst"
cluster_name   = "dct-gitops"
cluster_domain = "tst.k8s.local"

# Cluster network information
cluster_network_name = "kube-network"
cluster_network      = "10.0.10.0/24"
cluster_gateway      = "10.0.10.1"
cluster_vip          = "10.0.10.253"
cluster_endpoint     = "https://10.0.10.253:6443"

# Cluster node configuration
control_nodes = {
  control_01 = {
    node_name = "kub-control-01"
  }
}

worker_nodes = {
  worker_01 = {
    node_name = "kub-worker-01"
  }
}
