# Bootstrap

This directory contains the bootstrap configuration for setting up a new cluster with ArgoCD and Sealed Secrets.

## Prerequisites

- kubectl configured with cluster access
- SOPS installed
- Age key configured (export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt)
  - In a DR scenario the age keys.txt and private key can be retrieved from Azure Key Vault.

## Components

### Gateway API

Base networking component required for ingress configuration.

### Sealed Secrets

Initial secret management solution that enables encrypted secrets in git. Configuration in:

- Kustomization (reference `infra/bootstrap/sealed-secrets/kustomization.yaml`)
- Encrypted key (reference `infra/bootstrap/sealed-secrets/key/sealed-secrets-key.yaml`)
- Application manifest for ArgoCD management

### ArgoCD

GitOps controller that manages the cluster configuration. Includes:

- Base ArgoCD installation
- Project definitions
- OIDC configuration
- Repository credentials
- Custom configuration (reference `infra/bootstrap/argocd/overlays/argocd-cm.yaml`)

## Bootstrap Process

1. Creates required namespaces (argocd, kube-system)
2. Installs Gateway API CRDs
3. Deploys Sealed Secrets controller
4. Applies decrypted Sealed Secrets key
5. Installs ArgoCD
6. Applies root applications for ArgoCD and Sealed Secrets

## Usage

### Setup your Age key

```bash
export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt
```

### Bootstrap the cluster

Run the bootstrap script from the root of the repository.

```bash
./bootstrap.sh
```

## Post-Installation

After successful bootstrap, the application sets can be deployed on the cluster.