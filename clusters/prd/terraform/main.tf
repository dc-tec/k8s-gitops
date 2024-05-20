terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.6"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.13.2"
    }
  }
  required_version = "1.8.3"

  ## For testing, needs to be moved to a remote backend
  backend "local" {
    path = "terraform.tfstate"
  }
}
