set -euo pipefail

# Base directories
CLUSTER_DIR="$PWD/clusters"
CONFIG_DIR="$HOME/.kube/talos-clusters"
MERGED_DIR="$CONFIG_DIR/merged"

# Remove existing talos-clusters directory to ensure fresh configs
rm -rf "$CONFIG_DIR"

# Create directories if they don't exist
mkdir -p "$CONFIG_DIR/prd" "$CONFIG_DIR/tst" "$CONFIG_DIR/dev" "$MERGED_DIR"

# Function to export configs for an environment
export_configs() {
    local env=$1
    
    # Skip if not in correct terraform workspace
    if [[ "$env" != "dev" ]]; then
        (cd "$CLUSTER_DIR" && terraform workspace select "$env") || return 1
        (cd "$CLUSTER_DIR" && terraform output -raw talos_config) > "$CONFIG_DIR/$env/talosconfig"
        (cd "$CLUSTER_DIR" && terraform output -raw kubeconfig) > "$CONFIG_DIR/$env/kubeconfig"
        chmod 600 "$CONFIG_DIR/$env/talosconfig" "$CONFIG_DIR/$env/kubeconfig"
    fi
}

# Export configs for each environment
for env in prd tst; do
    export_configs "$env"
done

# Copy dev configs if they exist
if [[ -f "$CLUSTER_DIR/env/dev/talosconfig.yaml" ]]; then
    cp "$CLUSTER_DIR/env/dev/talosconfig.yaml" "$CONFIG_DIR/dev/talosconfig"
    cp "$CLUSTER_DIR/env/dev/kubeconfig" "$CONFIG_DIR/dev/kubeconfig"
    chmod 600 "$CONFIG_DIR/dev/talosconfig" "$CONFIG_DIR/dev/kubeconfig"
fi

# Merge talos configs
talosctl config merge \
    "$CONFIG_DIR/tst/talosconfig" \
    --talosconfig "$CONFIG_DIR/prd/talosconfig"

mv "$CONFIG_DIR/prd/talosconfig" "$MERGED_DIR/talosconfig"

# Merge kubeconfigs
KUBECONFIG=$(find "$CONFIG_DIR" -name kubeconfig -type f | tr '\n' ':') \
    kubectl config view --flatten > "$MERGED_DIR/kubeconfig"

# Set correct permissions
chmod 600 "$MERGED_DIR/talosconfig" "$MERGED_DIR/kubeconfig"

echo "Configs merged successfully:"
echo "TALOSCONFIG=$MERGED_DIR/talosconfig"
echo "KUBECONFIG=$MERGED_DIR/kubeconfig"