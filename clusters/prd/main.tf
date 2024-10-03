terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.6.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.15.0"
    }
  }
  required_version = "1.9.7"

  #TODO: make use of service principal 
  backend "azurerm" {
    resource_group_name  = "rg-dct-prd-westeu"
    storage_account_name = "dcttfbackendprod001"
    container_name       = "tfstate"
    key                  = "talos/prod.terraform.tfstate"
  }
}
