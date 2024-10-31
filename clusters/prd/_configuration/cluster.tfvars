# Generic cluster information
cluster_env    = "prd"
cluster_name   = "dct-gitops"
cluster_domain = "prd.k8s.local"

# Cluster network information
cluster_network_name = "kube-network"
cluster_network      = "10.0.10.0/24"
cluster_gateway      = "10.0.10.1"
cluster_vip          = "10.0.10.254"
cluster_endpoint     = "https://10.0.10.254:6443"

# Cluster node configuration
control_nodes = {
  control_01 = {
    node_name = "kub-control-01"
  }
  control_02 = {
    node_name = "kub-control-02"
  }
  control_03 = {
    node_name = "kub-control-03"
  }
}

worker_nodes = {
  worker_01 = {
    node_name = "kub-worker-01"
  }
  worker_02 = {
    node_name = "kub-worker-02"
  }
  worker_03 = {
    node_name = "kub-worker-03"
  }
}
