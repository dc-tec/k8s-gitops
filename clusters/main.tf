terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.1"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.6.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.16.1"
    }
  }
  required_version = "1.9.8"

  backend "azurerm" {
    resource_group_name  = "rg-dct-prd-westeu"
    storage_account_name = "dcttfbackendprod001"
    container_name       = "tfstate"
    key                  = "talos/prod.terraform.tfstate"
  }
}

module "talos_cluster" {
  source = "./modules/libvirt"

  cluster_gateway      = var.cluster_gateway
  cluster_endpoint     = var.cluster_endpoint
  cluster_domain       = var.cluster_domain
  cluster_network_name = var.cluster_network_name
  cluster_network      = var.cluster_network
  cluster_vip          = var.cluster_vip
  cluster_env          = var.cluster_env
  cluster_name         = var.cluster_network

  control_nodes = var.control_nodes
  worker_nodes  = var.worker_nodes
}
