#!/usr/bin/env -S just --justfile

set dotenv-load

env := "tst"

@_default:
    just --list

@set-context ENV=env:
    kubectl config use-context admin@{{ENV}}-dct-gitops
    talosctl config context {{ENV}}-dct-gitops
    cd ./cluster-infra/ && terraform workspace select {{ENV}}
    direnv allow .
    echo "Switched to {{ENV}} environment"

# Production environment commands
@init-prd:
    cd ./cluster-infra/ && terraform init -upgrade

@plan-prd:
    cd ./cluster-infra/ && terraform plan -var-file=env/prd/terraform.tfvars

@deploy-prd:
    cd ./cluster-infra/ && terraform apply -var-file=env/prd/terraform.tfvars -auto-approve

@shutdown-prd:
    talosctl shutdown --nodes $WORKERS && talosctl shutdown --nodes $CONTROLPLANE

# Test environment commands
@init-tst:
    cd ./cluster-infra/ && terraform init -upgrade

@plan-tst:
    cd ./cluster-infra/ && terraform plan -var-file=env/tst/terraform.tfvars

@deploy-tst:
    cd ./cluster-infra/ && terraform apply -var-file=env/tst/terraform.tfvars -auto-approve

@shutdown-tst:
    talosctl shutdown --nodes $WORKERS && talosctl shutdown --nodes $CONTROLPLANE

@delete-tst:
    cd ./cluster-infra/ && terraform destroy -var-file=env/tst/terraform.tfvars -auto-approve

@merge-configs:
    ./tools/config-merge.sh

