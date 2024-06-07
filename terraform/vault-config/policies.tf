# Demo-app policy
resource "vault_policy" "demo-app" {
  name = "demo-app"
  policy = file("policies/demo-app.hcl")
}


# Admin policy
resource "vault_policy" "admin" {
  name   = "admin"
  policy = file("policies/admin.hcl")
}
