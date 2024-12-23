# k8s-gitops

## Configuration

| cluster | platform     | OS    | control nodes | worker nodes |
| ------- | ------------ | ----- | ------------- | ------------ |
| prod    | libvirt/qemu | Talos | 3             | 3            |

The "prod" cluster is deployed using Terraform, see [cluster config](./clusters/prd/terraform/) and makes use of the Talos Kubernetes distribution. A base image is created using packer, see [packer config](./configs/packer).

For testing purposes, the "tst" cluster can be deployed using Terraform, see [cluster config](./clusters/tst/terraform/).

## Hardware

The "prod" cluster runs on a single host with the following specs:

| Component | Specification    |
| --------- | ---------------- |
| CPU       | AMD Ryzen 5 2600 |
| Memory    | 64GB DDR4        |
| Video     | RTX 2060 Super   |
| OS        | NixOS 24.11      |

## Bootstrap

The cluster is bootstrapped using a script that sets up the core components:

- Gateway API for ingress
- Sealed Secrets for secret management
- ArgoCD for GitOps deployment

See [bootstrap documentation](infra/bootstrap/README.md) for detailed setup instructions.

## Core Components

### ArgoCD

ArgoCD is configured with:

- OIDC authentication using EntraID
- Gateway API ingress
- [Custom RBAC configuration](infra/bootstrap/argocd/overlays/argocd-rbac-cm.yaml)
- Project structure for applications and infrastructure

### Secret Management

Two-tier approach to secret management:

1. Sealed Secrets

   - Used for bootstrap and initial secrets
   - Enables encrypted secrets in git
   - See [sealed-secrets configuration](infra/bootstrap/sealed-secrets/kustomization.yaml)

2. External Secrets (post-bootstrap) and HashiCorp Vault
   - Integration with Azure Key Vault
   - Used for application secrets
   - Managed by ArgoCD

## How to deploy

See [justfile](./justfile) for deployment instructions.
