resource "libvirt_network" "k8s" {
  name      = var.cluster_network_name
  mode      = "nat"
  domain    = var.cluster_domain
  addresses = [var.cluster_network]

  dns {
    enabled    = true
    local_only = false
  }

  dhcp {
    enabled = true
  }
}
