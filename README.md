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
k3d cluster create k3d-gitops --api-port 6443 -p 8080:80@loadbalancer -p 8443:443 --agents 2
```

## Deploying Cert-Manager

Run the following coomands to deploy cert-manager:

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.yaml
kubectl apply -f infrastruture/cert-manager/default-cert-issuer.yaml
kubectl apply -f infrastruture/cert-manager/dct-ca-issuer.yaml
kubectl apply -f infrastruture/cert-manager/dct-ca-cert.yaml
```
