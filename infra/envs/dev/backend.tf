terraform {
  backend "azurerm" {
    resource_group_name  = "rg-techflow-tfstate"
    storage_account_name = "sttechflowtfstate"
    container_name       = "tfstate"
    key                  = "dev/develop.tfstate"
    use_azuread_auth     = true
  }
}
