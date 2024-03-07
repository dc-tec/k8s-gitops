# k3d-gitops
Local K3D GitOps

## Preqrequisites
- [Docker](https://www.docker.com/)
- [K3D](https://k3d.io/)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

These tools can be installed using your favorite package manager. Or consult the documentation for each tool.

## Creating our cluster
Run the following command to start a 2-node K3D cluster with the name `k3d-gitops` and the default K3S version:
```bash
k3d cluster create k3d-gitops --api-port 6443 -p 8080@loadbalancer --agents 2
```
