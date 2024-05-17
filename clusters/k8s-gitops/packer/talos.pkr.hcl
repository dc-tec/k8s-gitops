packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "talos" {
  iso_url = "https://github.com/siderolabs/talos/releases/download/v1.7.2/metal-arm64.iso"
  iso_checksum = "3deaf676e7d784388e54ad10b9be8f829f5af2f8c63dd7c72ba9450bd3fdf238"
  output_directory = "output/talos"
  shutdown_command = "echo 'packer talos build' | sudo -S shutdown -h now"
  disk_size = "1500G"
  format = "qcow2"
  accelerator = "kvm"
  ssh_username = "root"
  ssh_password = "packer"
  ssh_timeout = "30m"
  vm_name = "talos"
  net_device = "virtio-net"
  disk_interface = "virtio"
  boot_wait = "20s"
  boot_command = [
    "<enter><wait1m>",
    "passwd<enter><wait>packer<enter><wait>packer<enter>",
    "ip address add ${var.static_ip} broadcast + dev enp27s0<enter><wait>",
    "ip route add 0.0.0.0/0 via ${var.gateway} dev enp27s0<enter><wait>"
  ]
}

build {
  sources = ["source.qemu.talos"]
}

