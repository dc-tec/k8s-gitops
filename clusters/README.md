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

| Name                                                                     | Version |
| ------------------------------------------------------------------------ | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | 1.9.8   |
| <a name="requirement_helm"></a> [helm](#requirement_helm)                | 2.16.1  |
| <a name="requirement_libvirt"></a> [libvirt](#requirement_libvirt)       | 0.8.1   |
| <a name="requirement_talos"></a> [talos](#requirement_talos)             | 0.6.1   |

## Providers

No providers.

## Modules

| Name                                                                       | Source            | Version |
| -------------------------------------------------------------------------- | ----------------- | ------- |
| <a name="module_talos_cluster"></a> [talos_cluster](#module_talos_cluster) | ./modules/libvirt | n/a     |

## Resources

No resources.

## Inputs

| Name                                                                                          | Description                                        | Type                                                     | Default        | Required |
| --------------------------------------------------------------------------------------------- | -------------------------------------------------- | -------------------------------------------------------- | -------------- | :------: |
| <a name="input_base_volume"></a> [base_volume](#input_base_volume)                            | The base volume for our Talos VM's                 | `string`                                                 | `"talos-base"` |    no    |
| <a name="input_cluster_domain"></a> [cluster_domain](#input_cluster_domain)                   | The domain kubernetes cluster domain name          | `string`                                                 | n/a            |   yes    |
| <a name="input_cluster_endpoint"></a> [cluster_endpoint](#input_cluster_endpoint)             | The endpoint for the kubernetes cluster            | `string`                                                 | n/a            |   yes    |
| <a name="input_cluster_env"></a> [cluster_env](#input_cluster_env)                            | The environment for the kubernetes cluster         | `string`                                                 | n/a            |   yes    |
| <a name="input_cluster_gateway"></a> [cluster_gateway](#input_cluster_gateway)                | The gateway for the kubernetes cluster             | `string`                                                 | n/a            |   yes    |
| <a name="input_cluster_name"></a> [cluster_name](#input_cluster_name)                         | The name of the cluster                            | `string`                                                 | n/a            |   yes    |
| <a name="input_cluster_network"></a> [cluster_network](#input_cluster_network)                | The network address for the kubernetes cluster     | `string`                                                 | n/a            |   yes    |
| <a name="input_cluster_network_name"></a> [cluster_network_name](#input_cluster_network_name) | The name of the network for the kubernetes cluster | `string`                                                 | n/a            |   yes    |
| <a name="input_cluster_vip"></a> [cluster_vip](#input_cluster_vip)                            | The virtual IP for the kubernetes cluster          | `string`                                                 | n/a            |   yes    |
| <a name="input_control_nodes"></a> [control_nodes](#input_control_nodes)                      | Control node configuration                         | <pre>map(object({<br/> node_name = string<br/> }))</pre> | n/a            |   yes    |
| <a name="input_worker_nodes"></a> [worker_nodes](#input_worker_nodes)                         | Worker node configuration                          | <pre>map(object({<br/> node_name = string<br/> }))</pre> | n/a            |   yes    |

## Outputs

| Name                                                                       | Description |
| -------------------------------------------------------------------------- | ----------- |
| <a name="output_control_nodes"></a> [control_nodes](#output_control_nodes) | n/a         |
| <a name="output_kubeconfig"></a> [kubeconfig](#output_kubeconfig)          | n/a         |
| <a name="output_talos_config"></a> [talos_config](#output_talos_config)    | n/a         |
| <a name="output_worker_nodes"></a> [worker_nodes](#output_worker_nodes)    | n/a         |

<!-- END_TF_DOCS -->
