# Deploying HashiCorp Vault Using Kind

## Prerequisites
1. [**Kubectl**]( https://kubernetes.io/docs/reference/kubectl/kubectl/) - Ensure `kubectl` is installed and configured.
2. [**Helm**](https://github.com/helm/helm/releases/tag/v3.15.1) - Ensure `helm` is installed.
3. [**Vault**](https://developer.hashicorp.com/vault/tutorials/getting-started/getting-started-install) - Ensure `Vault` is installed.    
4. [**Kind**](https://github.com/kubernetes-sigs/kind/releases) - Ensure `Kind` is installed.    


## Directory Structure
- **charts**: Contains Helm charts needed to deploy Vault and the demo app.
- **demo-app**: Contains code to get secrets from Vault and show them.
- **scripts**: Contains scripts to set up different engines and add sample data in Vault.
- **terraform**: Contains Terraform code for CI/CD to manage policies, roles, auth methods, etc.

## Introduction
In this demo, I will show how to use Vault sidecar injection with Kubernetes authentication to get secrets and put them in a file in the application pods.

First, I create a simple web server in Go that loads secret values as environment variables, logs them, and exits. This server is pushed to Docker Hub. The Vault sidecar retrieves the secret and puts it in a file.

```bash
GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o web -ldflags '-extldflags "-static"' main.go
docker build -t au06/demo-app:0.0.1 .
docker push au06/demo-app:0.0.1 
```

Next, I create a Helm chart for this demo app that includes a job, service account, and a configmap:
- **Job**: Loads the secret from a file as environment variables and prints it.
- **Service Account**: Used for authentication to the Vault via the Vault agent injector.
- **ConfigMap**: Contains the path of the secret created by the Vault agent injector.


![k8s Architecture](/assets/k8s-architecture.png)
![CI/CD Architecture](/assets/ci-cd.png)


## Steps to Setup Kind Cluster

### 1. Setup Kind
Download the latest stable release of Kind from their [GitHub releases page](https://github.com/kubernetes-sigs/kind/releases) for your supported platform.

### 2. Start the Kind Cluster
Create a new Kind cluster by running:
```bash
kind create cluster
```
This will create a cluster with context name: kind-kind
## Steps to Deploy HashiCorp Vault

### 3. Set Kubectl Context to the New Cluster
Ensure `kubectl` is pointing to the newly created Kind cluster. You can check and switch contexts using:

Check Context:
```bash
kubectl config current-context
```

Switch Context: 
```bash
kubectl config use-context kind-kind
```

### 4. Create a Namespace for Vault
Create a namespace for deploying Vault:
```bash
kubectl create namespace vault
```

### 5. Switch to the Vault Namespace
Switch to the `vault` namespace:
```bash
kubens vault
```

### 6. Pull the Latest Vault Helm Charts
Add the HashiCorp Helm repository and pull the Vault chart:
```bash
helm repo add hashicorp https://helm.releases.hashicorp.com
helm search repo hashicorp/vault
helm pull hashicorp/vault --untar
```

### 7. Deploy Vault in Development Mode
For this demo, we will deploy Vault in development mode which allows for the auto-unseal mechanism. For a production setup, it is recommended to deploy Vault in production mode which supports Raft, HA, and auto-unseal using a KMS.

### 8. Deploy Vault Using Helm
Deploy Vault using Helm with the necessary parameters:
```bash
helm install vault hashicorp/vault --set "global.namespace=vault" --set "server.dev.enabled=true"
```
### 9. Port Forward the Vault Service
Since this is a local cluster, port forward the Vault service:
```bash
kubectl port-forward svc/vault 8200
```
### 10. Populate Vault with Secrets
Once Vault is accessible on localhost, run the add-secret.sh script located in the scripts folder to enable engines and populate some secrets.

### 11. Enable Kubernetes Authentication
Run terraform plan and terraform apply to enable Kubernetes-based authentication, creating necessary policies to allow the demo-app Vault sidecar to retrieve secrets at a specified path.

### 12. Vault Verification
Access the vault server in browser at http://localhost:8200. Since the server is running in dev mode the default token is "root" . Use this to login and verify if everything is in place.

### 13. Deploy the Demo App
Deploy the demo-app using the Helm charts in the demo namespace.
```bash
helm template demo-app charts/demo-app > manifest.yaml
kubectl apply -f ./manifest.yaml -n demo
```


## How This Approach Works
- **Kubernetes Authentication**: Enable the Kubernetes authentication method, providing the Kubernetes host address.
- **Policies**: Create policies that define permissions for secrets.
- **Service Account**: Tie Kubernetes service account and namespace from which the service will retrieve secrets with this Kubernetes auth.

This approach ensures that individual applications can run and connect with Vault without having to pass any credentials, requiring only a one-time setup.

## Deployment Pipeline
### Part 1: Deployment of Service and Vault
1. Host ArgoCD and connect it to the target cluster hosting Vault and the demo-app.
2. Push both the charts to remote storage and a Git repo holding its values. Any change in values will be picked up by ArgoCD, updating the demo-app or Vault.

### Part 2: Management of Vault Entities
1. Push the Terraform code to a GitHub repo.
2. Set up Terraform with a remote backend.
3. Provide credentials with necessary privileges to execute changes on the Vault server.

## Managing Ongoing Changes
Ongoing changes can be managed by the above CI/CD setup:
- Via Terraform, enable/disable different types of auth mechanisms.
- Using ArgoCD, deploy different services on various chart iterations.

## Authentication Mechanism
Among various auth mechanisms like token, app role and ID, JWT token, and Kubernetes auth, I prefer Kubernetes auth due to its security. Retrieval of secrets is only possible if a configured service account from a configured namespace makes the request using a specific role. This setup avoids the need for token management, like rotation.

## Configuring and Maintaining Vault Policies
Depending upon requirements, utilize the Terraform CI/CD pipeline to enable/disable various auth mechanisms, and manage the creation and management of various roles and policies.



## Notes
- **Development Mode**: The `server.dev.enabled=true` parameter enables development mode, which is not suitable for production environments due to its lack of security features.
- **Production Setup**: For a production setup, consider using parameters that enable High Availability (HA), Raft storage backend, and secure auto-unseal mechanisms using a Key Management Service (KMS).

For detailed configurations and advanced setups, refer to the [HashiCorp Vault Helm Chart Documentation](https://github.com/hashicorp/vault-helm).