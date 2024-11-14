#!/bin/bash

# Check if SOPS_AGE_KEY_FILE is set
if [ -z "$SOPS_AGE_KEY_FILE" ]; then
    echo "Error: SOPS_AGE_KEY_FILE environment variable is not set"
    echo "Please set it to the path of your age key file (e.g., export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt)"
    exit 1
fi

# Create required namespaces
echo "Creating namespaces..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace kube-system --dry-run=client -o yaml | kubectl apply -f -

# Install Gateway API
echo "Installing Gateway API..."
kubectl apply -k infra/bootstrap/gateway-api

# Install sealed-secrets controller first
echo "Installing sealed-secrets controller..."
kubectl apply -k infra/bootstrap/sealed-secrets

# Wait for sealed-secrets controller to be ready
echo "Waiting for sealed-secrets controller..."
kubectl wait --for=condition=available --timeout=300s deployment/sealed-secrets-controller -n kube-system

# Decrypt and apply the sealed-secrets key
echo "Decrypting sealed-secrets key..."
sops --decrypt infra/bootstrap/sealed-secrets/key/sealed-secrets-key.yaml | kubectl apply -f -

# Apply ArgoCD installation
echo "Installing ArgoCD..."
kubectl apply -k infra/bootstrap/argocd

# Wait for ArgoCD to be ready
echo "Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Apply the root applications
echo "Applying the rootapplications..."
kubectl apply -f infra/bootstrap/argocd/application.yaml
kubectl apply -f infra/bootstrap/sealed-secrets/application.yaml
