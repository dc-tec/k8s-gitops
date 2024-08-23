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
      version = "2.14.0"
    }
  }
  required_version = "1.8.5"

  #TODO: make use of service principal 
  backend "azurerm" {
    resource_group_name  = "rg-dct-prd-westeu"
    storage_account_name = "dcttfbackendprod001"
    container_name       = "tfstate"
    key                  = "talos/prod.terraform.tfstate"
  }
}
