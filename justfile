#!/usr/bin/env -S just --justfile

set dotenv-load

env := "tst"

@_default:
    just --list

@set-context ENV=env:
    kubectl config use-context admin@{{ENV}}-dct-gitops
    talosctl config context {{ENV}}-dct-gitops
    cd ./clusters/ && terraform workspace select {{ENV}}
    direnv allow .
    echo "Switched to {{ENV}} environment"

# Production environment commands
@plan-prd:
    cd ./clusters/ && terraform plan -var-file=env/prd/terraform.tfvars

@deploy-prd:
    cd ./clusters/ && terraform apply -var-file=env/prd/terraform.tfvars -auto-approve

@shutdown-prd:
    talosctl shutdown --nodes $WORKERS && talosctl shutdown --nodes $CONTROLPLANE

# Test environment commands
@plan-tst:
    cd ./clusters/ && terraform plan -var-file=env/tst/terraform.tfvars

@deploy-tst:
    cd ./clusters/ && terraform apply -var-file=env/tst/terraform.tfvars -auto-approve

@shutdown-tst:
    talosctl shutdown --nodes $WORKERS && talosctl shutdown --nodes $CONTROLPLANE

@delete-tst:
    cd ./clusters/ && terraform destroy -var-file=env/tst/terraform.tfvars -auto-approve

# Bootstrap cluster with ArgoCD and core components
@bootstrap: (_check-prereqs)
    ./tools/bootstrap.sh

# Merge configuration files
@merge-configs:
    ./tools/config-merge.sh

# Private recipe to check prerequisites
@_check-prereqs:
    command -v kubectl >/dev/null 2>&1 || { echo "kubectl is required but not installed"; exit 1; }
    command -v sops >/dev/null 2>&1 || { echo "sops is required but not installed"; exit 1; }
    test -n "$$SOPS_AGE_KEY_FILE" || { echo "SOPS_AGE_KEY_FILE must be set"; exit 1; }

