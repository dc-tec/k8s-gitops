resource "libvirt_volume" "control_node" {
  for_each = var.control_nodes

  name             = "${var.cluster_env}-${each.value.node_name}.img"
  base_volume_name = var.base_volume
  format           = "qcow2"
  size             = 40 * 1024 * 1024 * 1024 # 40 GB
}

resource "libvirt_volume" "worker_node" {
  for_each = var.worker_nodes

  name             = "${var.cluster_env}-${each.value.node_name}.img"
  base_volume_name = var.base_volume
  format           = "qcow2"
  size             = 40 * 1024 * 1024 * 1024 # 40 GB
}

resource "libvirt_volume" "worker_node_data_0" {
  for_each = var.worker_nodes

  name   = "${var.cluster_env}-${each.value.node_name}-data0.img"
  format = "qcow2"
  size   = 50 * 1024 * 1024 * 1024 # 50 GB
}

resource "libvirt_domain" "control_node" {
  for_each = var.control_nodes

  name     = "${var.cluster_env}-${each.value.node_name}"
  machine  = "q35"
  firmware = "/run/libvirt/nix-ovmf/OVMF_CODE.fd"

  vcpu   = 2
  memory = 4 * 1024 # 4 GB

  cpu {
    mode = "host-passthrough"
  }

  disk {
    volume_id = libvirt_volume.control_node[each.key].id
    scsi      = true
  }

  network_interface {
    network_id     = libvirt_network.k8s.id
    addresses      = [each.value.ip_address]
    wait_for_lease = true
  }

  video {
    type = "qxl"
  }

  qemu_agent = false

  lifecycle {
    ignore_changes = [
      nvram,
      disk[0].wwn
    ]
  }
}

resource "libvirt_domain" "worker_node" {
  for_each = var.worker_nodes

  name     = "${var.cluster_env}-${each.value.node_name}"
  machine  = "q35"
  firmware = "/run/libvirt/nix-ovmf/OVMF_CODE.fd"

  vcpu   = 2
  memory = 4 * 1024 # 4 GB

  cpu {
    mode = "host-passthrough"
  }

  disk {
    volume_id = libvirt_volume.worker_node[each.key].id
    scsi      = true
  }

  disk {
    volume_id = libvirt_volume.worker_node_data_0[each.key].id
    scsi      = true
  }

  network_interface {
    network_id     = libvirt_network.k8s.id
    addresses      = [each.value.ip_address]
    wait_for_lease = true
  }

  video {
    type = "qxl"
  }

  qemu_agent = false

  lifecycle {
    ignore_changes = [
      nvram,
      disk[0].wwn,
      disk[1].wwn
    ]
  }

}

