# admin-policy.hcl
path "secret/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "internal/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}