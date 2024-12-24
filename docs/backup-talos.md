# Talos Cluster Backup & Recovery

This document outlines the backup configuration and recovery procedures for our Talos Kubernetes cluster.

## Backup Configuration

We use a CronJob to automatically backup the etcd database to Backblaze B2 storage. The backup is encrypted using age encryption.

### Components

- CronJob running `talos-backup` container
- Backblaze B2 bucket for storage
- Age encryption for backup security
- ServiceAccount with `os:etcd:backup` role
- Sealed secrets for credentials

### Prerequisites

1. Backblaze B2 bucket and credentials
2. Age public key for encryption
3. Talos ServiceAccount configured with backup permissions

### Deployment

The backup is deployed using a Kustomization. The secrets are sealed and stored in the cluster.

`kubectl apply -k kubernetes/backups/talos`

## Recovery Procedure

### 1. Verify Unrecoverable State

Before starting recovery, verify that the etcd cluster cannot be restored:

```sh
# Check etcd member list across healty nodes
talosctl -n <IP> etcd members

# Check etcd cluster health
talosctl -n <IP> service etcd
```

### 2. Prepare for Recovery

1. Ensure no control plane nodes are of type `init`:

```sh
talosctl -n <IP1>,<IP2>,... get machinetype
```

2. For failed hardware:

   - Replace nodes using backed-up machine configuration
   - Update control plane endpoint if node IPs changed

3. For corrupted etcd:
   - Wipe the node's EPHEMERAL partition:

```sh
talosctl -n <IP> reset --graceful=false --reboot --system-labels-to-wipe=EPHEMERAL
```

### 3. Restore from Backup

1. Verify all etcd services are in `Preparing` state:

```sh
talosctl -n <IP> service etcd
```

2. Download backup from B2 storage

3. Execute bootstrap command with backup:

```sh
talosctl -n <IP> bootstrap --recover-from=./backup.snapshot
```

4. Wait for etcd to become healthy and control plane components to start

### Verification

After recovery:

1. Check etcd health
2. Verify Kubernetes API server is responding
3. Check node status
4. Verify workload functionality

## Reference

- [Talos Disaster Recovery Documentation](https://www.talos.dev/v1.9/advanced/disaster-recovery/)
