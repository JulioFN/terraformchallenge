resource "azurerm_lb" "lb" {
    location = var.azure_region_name
    name = "lb"
    resource_group_name = var.azure_resource_group_name
    sku = "Standard"
    
    frontend_ip_configuration {
      name = var.frontend_ip_configuration_name
      private_ip_address_allocation = "Dynamic"
      subnet_id = var.azure_snet_id
    }
}