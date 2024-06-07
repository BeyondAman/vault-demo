

# K8s authnetication
resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
  path = "kubernetes"
}


resource "vault_kubernetes_auth_backend_config" "kubernetes" {
  backend = vault_auth_backend.kubernetes.path

  kubernetes_host = "${var.kubernetes_host}"
}


# Linking OF K8s service account and namespace to a vault role
resource "vault_kubernetes_auth_backend_role" "demo-app" {

  backend = vault_auth_backend.kubernetes.path
  role_name = "demo-app"

  bound_service_account_names = ["vault-demo"]
  bound_service_account_namespaces = ["demo"]

  token_policies = ["demo-app"]
  token_ttl = "3600"
}