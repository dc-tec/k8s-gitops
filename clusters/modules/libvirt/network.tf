resource "libvirt_network" "k8s" {
  name      = var.cluster_network_name
  mode      = "bridge"
  bridge    = "br0"
  autostart = true

  dhcp {
    enabled = false
  }

  dns {
    enabled    = true
    local_only = false
  }
}
