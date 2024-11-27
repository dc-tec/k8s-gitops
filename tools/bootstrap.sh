set -euo pipefail

# Function to wait for CRD
wait_for_crd() {
    local CRD=$1
    echo "Waiting for CRD $CRD..."
    while ! kubectl get crd $CRD &>/dev/null; do
        sleep 2
    done
}

# Function to wait for namespace
wait_for_namespace() {
    local NS=$1
    echo "Waiting for namespace $NS..."
    while ! kubectl get namespace $NS &>/dev/null; do
        sleep 2
    done
}

# Check if SOPS_AGE_KEY_FILE is set
if [ -z "${SOPS_AGE_KEY_FILE:-}" ]; then
    echo "Error: SOPS_AGE_KEY_FILE environment variable is not set"
    echo "Please set it to the path of your age key file (e.g., export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt)"
    exit 1
fi

# Parse command-line arguments
INSTALL_ARGOCD=false
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -argocd|--argocd) INSTALL_ARGOCD=true ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Create required namespaces
echo "Creating namespaces..."
kubectl create namespace kube-system --dry-run=client -o yaml | kubectl apply -f -

# Install Gateway API CRDs
echo "Installing Gateway API CRDs..."
kubectl apply -k infra/bootstrap/gateway-api

# Install sealed-secrets controller
echo "Installing sealed-secrets controller..."
kubectl apply -k infra/bootstrap/sealed-secrets

# Wait for sealed-secrets CRD and controller
wait_for_crd "sealedsecrets.bitnami.com"
echo "Waiting for sealed-secrets controller..."
kubectl wait --for=condition=available --timeout=300s deployment/sealed-secrets-controller -n kube-system

# Check and remove existing sealed-secrets key if it exists
SEALED_SECRET_KEY=$(kubectl get secrets -n kube-system -o name | grep "sealed-secrets-key" || true)
if [ -n "$SEALED_SECRET_KEY" ]; then
    echo "Found existing sealed-secrets key, removing..."
    kubectl delete "$SEALED_SECRET_KEY" -n kube-system
else
    echo "No existing sealed-secrets key found, continuing..."
fi

# Decrypt and apply the sealed-secrets key
echo "Decrypting sealed-secrets key..."
sops --decrypt infra/bootstrap/sealed-secrets/key/sealed-secrets-key.yaml | kubectl apply -f -

# Delete existing sealed-secrets controller
echo "Deleting existing sealed-secrets controller..."
kubectl delete pod -n kube-system -l name=sealed-secrets-controller

# Wait for sealed-secrets controller to be ready
echo "Waiting for sealed-secrets controller to be ready..."
kubectl wait --for=condition=ready --timeout=300s pod -l name=sealed-secrets-controller -n kube-system

# Install ArgoCD if requested
if [ "$INSTALL_ARGOCD" = true ]; then
    echo "Installing ArgoCD..."
    kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
    wait_for_namespace "argocd"
    kubectl apply -k infra/bootstrap/argocd

    # Wait for critical ArgoCD components
    echo "Waiting for ArgoCD components..."
    kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
    kubectl wait --for=condition=available --timeout=300s deployment/argocd-repo-server -n argocd
    kubectl wait --for=condition=available --timeout=300s deployment/argocd-applicationset-controller -n argocd
    kubectl wait --for=condition=available --timeout=300s deployment/argocd-redis -n argocd
fi

echo "Bootstrap completed successfully!"