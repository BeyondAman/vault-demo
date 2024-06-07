
# Variable to Set the K8s host address for vault authentication mechanism
variable "kubernetes_host" {
  description = "The host address including port of the Kubernetes API server"
  type        = string
}

# Variable to set the vault address to setup connectivity with it
variable "vault_address" {
  description = "The host address including port of the Kubernetes API server"
  type        = string
}

# Variable to set the token needed to authenticate with vault
variable "vault_token" {
  description = "The host address including port of the Kubernetes API server"
  type        = string
}
