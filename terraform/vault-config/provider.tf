terraform {
  required_version = "1.8.5"
}

# Provider configuration for Vault
provider "vault" {
  address = "${var.vault_address}"
  token   = "${var.vault_token}" 
}
