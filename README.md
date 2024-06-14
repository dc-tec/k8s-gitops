# k8s-gitops

## Configuration

| cluster | platform     | OS    | control nodes | worker nodes |
| ------- | ------------ | ----- | ------------- | ------------ |
| prod    | libvirt/qemu | Talos | 3             | 3            |

The "prod" cluster is deployed using Terraform, see [cluster config](./clusters/prd/terraform/) and makes use of the Talos Kubernetes distribution. A base image is created using packer, see [packer config](./configs/packer).

## Hardware

The "prod" cluster runs on a single host with the following specs:

| Component | Specification    |
| --------- | ---------------- |
| CPU       | AMD Ryzen 5 2600 |
| Memory    | 64GB DDR4        |
| Video     | RTX 2060 Super   |
| OS        | NixOS 24.11      |

## GitOps

### ArgoCD

Applications and services inside of the cluster are deployed via ArgoCD using Kustomize. This makes deployment very flexibel, but also ensures a consistent way of deploying resources.

ArgoCD is internally exposed through the Kubernetes Gateway API, using cilium.

EntraID is used to authenticate on the Web UI.

### Secret Management

In order to work with secrets inside of the cluster two different services are used:

- Sealed Secrets
- External Secrets using Azure Keyvault

See [secret management](./docs/secret-management.md) how to create secrets using sealed-secrets.

### Certificate Management

In order to provide services with a valid TLS certificate, `Cert-Manager` is used in DNS-01 challenge mode using Cloudflare DNS.
