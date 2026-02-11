# Resource group y naming
resource_group_name = "rg-techflow-dev"
prefix              = "techflowdev"
location            = "eastus"

# KeyVault
keyvault_name = "techflowdevkv"

# ACR
acr_name = "techflowdevacr"

# IMPORTANT:
# Object IDs que tendrán "Key Vault Secrets Officer" en el vault.
# Para tu caso: Service Principal objectId (OID del SP)
keyvault_secrets_officer_principal_ids = [
  "25cbc7ed-7342-4156-b6a1-805c61638927"
]
