resource "azurerm_container_registry" "this" {
  name                = "${lower(replace(replace(replace(replace(var.prefix, "-", ""), "_", ""), " ", ""), ".", ""))}acr"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku           = "Basic"
  admin_enabled = false
}
