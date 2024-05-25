# Generic cluster information
cluster_env    = "prd"
cluster_name   = "dct-gitops"
cluster_domain = "prd.k8s.local"

# Cluster network information
cluster_network_name = "kube-network"
cluster_network      = "172.50.0.0/24"
cluster_vip          = "172.50.0.254"
cluster_endpoint     = "https://172.50.0.254:6443"

# Cluster node configuration
control_nodes = {
  control_01 = {
    node_name  = "kub-control-01"
    ip_address = "172.50.0.2"
  }
  control_02 = {
    node_name  = "kub-control-02"
    ip_address = "172.50.0.3"
  }
  control_03 = {
    node_name  = "kub-control-03"
    ip_address = "172.50.0.4"
  }
}

worker_nodes = {
  worker_01 = {
    node_name  = "kub-worker-01"
    ip_address = "172.50.0.20"
  }
  worker_02 = {
    node_name  = "kub-worker-02"
    ip_address = "172.50.0.21"
  }
  worker_03 = {
    node_name  = "kub-worker-03"
    ip_address = "172.50.0.22"
  }
}
