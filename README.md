# k8s-gitops

## Configuration

| cluster | platform     | OS    | control nodes | worker nodes |
| ------- | ------------ | ----- | ------------- | ------------ |
| prod    | libvirt/qemu | Talos | 3             | 3            |

The prod cluster is deployed using Terraform, see [cluster config](./clusters/prd/terraform/) and makes use of the Talos Kubernetes distribution. A base image is created using packer, see [packer config](./configs/packer).
