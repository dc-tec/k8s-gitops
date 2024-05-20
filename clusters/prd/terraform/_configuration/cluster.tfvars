cluster_env          = "prd"
cluster_domain       = "prd.k8s.local"
cluster_network_name = "kube-network"
cluster_network      = "172.50.0.0/24"

control_nodes = {
  control_01 = {
    node_name  = "kub-control-01"
    ip_address = "172.50.0.2"
  }
  #  control_02 = {
  #    node_name  = "kub-control-02"
  #    ip_address = ""
  #  }
  #  control_03 = {
  #    node_name  = "kub-control-03"
  #    ip_address = ""
  #  }
}

worker_nodes = {
  worker_01 = {
    node_name  = "kub-worker-01"
    ip_address = "172.50.0.20"
  }
  #  worker_02 = {
  #    node_name  = "kub-worker-02"
  #    ip_address = ""
  #  }
  #  worker_03 = {
  #    node_name  = "kub-worker-03"
  #    ip_address = ""
  #  }
}
