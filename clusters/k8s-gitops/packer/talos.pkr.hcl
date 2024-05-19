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
  shutdown_command = "echo 'packer talos build' | doas poweroff"
  disk_size = "15G"
  format = "qcow2"
  accelerator = "kvm"
  ssh_username = "packer"
  ssh_password = "packer"
  ssh_timeout = "30m"
  vm_name = "talos"
  net_device = "virtio-net"
  disk_interface = "virtio"
  memory = 4096
  boot_wait = "20s"
  boot_command = [
    "root<enter><wait>",
    "setup-alpine<enter><wait>",
    "us<enter><wait>", # Set kb layout
    "us-intl<enter><wait>", # Us international
    "<enter><wait5s>", # hostname, we can keep this as localhost
    "<enter><wait5s>", # Interface, we can keep this as eth0
    "<enter><wait5s>", # IP, we can keep this as dhcp
    "n<enter><wait5s>", # No manual network configuration
    "packer<enter><wait5s>", # Define temp password
    "packer<enter><wait5s>", # Confirm temp password
    "<enter><wait5s>", # Timezone, keep as UTC
    "<enter><wait5s>", # We do not need to configure a proxy
    "<enter><wait5s>", # We just use the first mirror for the setup
    "packer<enter><wait5s>", # Create the packer user
    "<enter><wait5s>", # Default full name
    "packer<enter><wait5s>", # Default password for packer user
    "packer<enter><wait5s>", # Confirm password for packer user
    "<enter><wait5s>", # No additional ssh keys to define
    "<enter><wait5s>", # Default to openssh
    "<enter><wait5s>", # We do not need to configure a disk
    "<enter><wait5s>", # We do not need to configure a place to store configs
    "<enter><wait5s>", # keep default apk cache
    "cat << EOF > /etc/ssh/ssh_config<enter><wait>",
    "Host *<enter>",
    "  PasswordAuthentication yes<enter>",
    "  PermitRootLogin yes<enter>",
    "EOF<enter>",
    "service sshd restart<enter><wait>",
    "cat << EOF > /etc/doas.d/doas.conf<enter><wait>",
    "permit nopass packer<enter>",
    "EOF<enter>",
  ]
}

build {
  sources = ["source.qemu.talos"]

  provisioner "shell" {
    inline = [
      "doas apk add curl xz",
      "curl -L ${var.talos_image} -o /tmp/talos.raw.xz",
      "xz -d -c /tmp/talos.raw.xz | doas dd of=/dev/vda && sync"
    ]
  }
}

