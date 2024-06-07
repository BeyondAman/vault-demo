# Policy only allowing access at the below specific path
path "internal/database/config" {
  capabilities = ["read"]
}

path "internal/data/database/config" {
  capabilities = ["read"]
}