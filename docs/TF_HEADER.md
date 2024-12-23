# Talos Kubernetes Cluster Infrastructure

This repository contains the Terraform configuration for managing Talos-based Kubernetes clusters across different environments.

## Architecture

The infrastructure is organized as a Terraform module that provisions:

- Talos control plane nodes
- Talos worker nodes
- Network configuration
- Cilium CNI with L2 announcements
- Longhorn storage configuration

## Prerequisites

- Terraform >= 1.9.8
- QEMU/KVM
- Talos >= v1.8.2
- Azure Storage Account (for Terraform state)

## Deployment

### Initialize Terraform

```bash
terraform init
```

### Select the correct workspace

**PROD**

```bash
terraform workspace select prd
```

**TEST**

```bash
terraform workspace select tst
```

### Plan

```bash
terraform plan -var-file=env/${ENV}/terraform.tfvars
```

### Apply

```bash
terraform apply -var-file=env/${ENV}/terraform.tfvars
```

### Development Environment

Development environment doesn't use Terraform. Instead, use talosctl:

```bash
talosctl cluster create --talosconfig=env/dev/talosconfig.yaml
```
