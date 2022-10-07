output "vm_public_ips" {
    value = module.azurevms[*].vm_public_ip
}