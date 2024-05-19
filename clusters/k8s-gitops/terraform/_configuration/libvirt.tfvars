cluster_domain       = "dev.k8s.local"
cluster_network_name = "kube-network"
cluster_network      = "172.50.0.0/24"

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
