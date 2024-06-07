#!/bin/bash

# Vault Address
export VAULT_ADDR="http://localhost:8200"

# Vault Token
export VAULT_TOKEN="root"

# Secret Path
SECRET_PATH="secret/sample-app"
INT_SECRET_PATH="internal/database/config"

# Secrets
USERNAME="Aman-upadhyay"
PASSWORD="yBcRr4DRJEsTKLg"

# Add secrets to Vault
vault kv put $SECRET_PATH username=$USERNAME password=$PASSWORD

echo "Secrets added to Vault successfully!"

# Enabling Internal Path
vault secrets enable -path=internal kv-v2

# Adding Internal Secret to Vault
vault kv put $INT_SECRET_PATH  username=$USERNAME password=$PASSWORD
