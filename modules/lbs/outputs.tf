output "lb_id" {
    value = azurerm_lb.lb.id
}

output "lb_frontend_private_ip_address" {
    value = one(azurerm_lb.lb.frontend_ip_configuration[*].private_ip_address)
}

output "lb_frontend_id" {
    value = one(azurerm_lb.lb.frontend_ip_configuration[*].id)
}