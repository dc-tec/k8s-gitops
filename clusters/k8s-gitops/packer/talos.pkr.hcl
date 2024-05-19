packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "talos" {
  iso_url = ".content/alpine-3.19.1.iso"
  iso_checksum = "63e62f5a52cfe73a6cb137ecbb111b7d48356862a1dfe50d8fdd977d727da192"
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
  memory = 4096
  boot_wait = "20s"
  boot_command = [
    "<enter><wait1m>",
    "root<enter><wait>",
    "ip address add ${var.static_ip} broadcast + dev eth0<enter><wait>",
    "ip route add 0.0.0.0/0 via ${var.gateway} dev eth0<enter><wait>",
    "setup-alpine<enter><wait>"
  ]
}

build {
  sources = ["source.qemu.talos"]

  provisioner "shell" {
    inline = [
      "apk add curl xz",
      "curl -L ${var.talos_image} -o /tmp/talos.raw.xz",
      "xz -d -c /tmp/talos.raw.xz | dd of=/dev/sda && sync"
    ]
  }
}

