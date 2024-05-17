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

resource "libvirt_network" "build_network" {
  name      = "packer_build_network"
  mode      = "nat"
  addresses = ["10.240.0.0/28"]

  dhcp {
    enabled = true
  }
}
