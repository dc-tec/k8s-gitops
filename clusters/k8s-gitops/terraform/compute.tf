resource "libvirt_volume" "control_node" {
  for_each = var.control_nodes

  name             = "${each.value.node_name}.img"
  base_volume_name = var.base_volume
  format           = "qcow2"
  size             = 40 * 1024 * 1024 * 1024 # 40 GB
}

resource "libvirt_volume" "worker_node" {
  for_each = var.worker_nodes

  name             = "${each.value.node_name}.img"
  base_volume_name = var.base_volume
  format           = "qcow2"
  size             = 40 * 1024 * 1024 * 1024 # 40 GB
}

resource "libvirt_volume" "worker_node_data_0" {
  for_each = var.worker_nodes

  name   = "${each.value.node_name}-data0.img"
  format = "qcow2"
  size   = 50 * 1024 * 1024 * 1024 # 50 GB
}

