#!/usr/bin/env -S just --justfile

set dotenv-load

env := "tst"

@set-context ENV=env:
    kubectl config use-context admin@{{ENV}}-dct-gitops
    talosctl config context {{ENV}}-dct-gitops
    cd ./clusters/ && terraform workspace select {{ENV}}
    direnv allow .
    echo "Switched to {{ENV}} environment"

@plan-prd:
    echo "Planning prd environment..."
    cd ./clusters/ && terraform workspace select prd && terraform plan -var-file=env/prd/terraform.tfvars

@deploy-prd:
    echo "Deploying prd environment..."
    cd ./clusters/ && terraform workspace select prd && terraform apply -var-file=env/prd/terraform.tfvars -auto-approve
    set-context prd

@plan-tst:
    echo "Planning tst environment..."
    cd ./clusters/ && terraform workspace select tst && terraform plan -var-file=env/tst/terraform.tfvars

@deploy-tst:
    echo "Deploying tst environment..."
    cd ./clusters/ && terraform workspace select tst && terraform apply -var-file=env/tst/terraform.tfvars -auto-approve
    set-context tst

@delete-tst:
    echo "Deleting tst environment..."
    cd ./clusters/ && terraform workspace select tst && terraform destroy -var-file=env/tst/terraform.tfvars -auto-approve

@bootstrap:
    ./tools/bootstrap.sh

@merge-configs:
    ./tools/config-merge.sh


