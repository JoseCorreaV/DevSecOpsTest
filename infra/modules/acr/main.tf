resource "azurerm_container_registry" "this" {
  name                = "${var.prefix}acr"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku           = "Basic"
  admin_enabled = false

  # Esto sí aplica (aunque no necesariamente te quita todos los checks)
  public_network_access_enabled = true
  export_policy_enabled         = true
  network_rule_bypass_option    = "AzureServices"
}
