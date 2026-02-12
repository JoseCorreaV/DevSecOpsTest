resource "azurerm_container_registry" "this" {
  name                = "${lower(replace(var.prefix, "/[^0-9A-Za-z]/", ""))}acr"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku           = "Basic"
  admin_enabled = false
}
