<!-- BEGIN_TF_DOCS -->
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

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.9.8 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.16.1 |
| <a name="requirement_libvirt"></a> [libvirt](#requirement\_libvirt) | 0.8.1 |
| <a name="requirement_talos"></a> [talos](#requirement\_talos) | 0.6.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_libvirt"></a> [libvirt](#provider\_libvirt) | 0.8.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_talos_cluster"></a> [talos\_cluster](#module\_talos\_cluster) | ./modules/libvirt | n/a |

## Resources

| Name | Type |
|------|------|
| [libvirt_network.k8s](https://registry.terraform.io/providers/dmacvicar/libvirt/0.8.1/docs/resources/network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_base_volume"></a> [base\_volume](#input\_base\_volume) | The base volume for our Talos VM's | `string` | `"talos-base"` | no |
| <a name="input_cluster_domain"></a> [cluster\_domain](#input\_cluster\_domain) | The domain kubernetes cluster domain name | `string` | n/a | yes |
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | The endpoint for the kubernetes cluster | `string` | n/a | yes |
| <a name="input_cluster_env"></a> [cluster\_env](#input\_cluster\_env) | The environment for the kubernetes cluster | `string` | n/a | yes |
| <a name="input_cluster_gateway"></a> [cluster\_gateway](#input\_cluster\_gateway) | The gateway for the kubernetes cluster | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the cluster | `string` | n/a | yes |
| <a name="input_cluster_network"></a> [cluster\_network](#input\_cluster\_network) | The network address for the kubernetes cluster | `string` | n/a | yes |
| <a name="input_cluster_network_name"></a> [cluster\_network\_name](#input\_cluster\_network\_name) | The name of the network for the kubernetes cluster | `string` | n/a | yes |
| <a name="input_cluster_vip"></a> [cluster\_vip](#input\_cluster\_vip) | The virtual IP for the kubernetes cluster | `string` | n/a | yes |
| <a name="input_control_nodes"></a> [control\_nodes](#input\_control\_nodes) | Control node configuration | <pre>map(object({<br>    node_name = string<br>    vcpu      = optional(number)<br>    memory    = optional(number)<br>  }))</pre> | n/a | yes |
| <a name="input_worker_nodes"></a> [worker\_nodes](#input\_worker\_nodes) | Worker node configuration | <pre>map(object({<br>    node_name      = string<br>    vcpu           = optional(number)<br>    memory         = optional(number)<br>    data_disk_size = optional(number)<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_env"></a> [cluster\_env](#output\_cluster\_env) | The environment for the cluster |
| <a name="output_control_nodes"></a> [control\_nodes](#output\_control\_nodes) | The control nodes for the cluster |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | The kubeconfig for the cluster |
| <a name="output_talos_config"></a> [talos\_config](#output\_talos\_config) | The Talos configuration for the cluster |
| <a name="output_worker_nodes"></a> [worker\_nodes](#output\_worker\_nodes) | The worker nodes for the cluster |
<!-- END_TF_DOCS -->