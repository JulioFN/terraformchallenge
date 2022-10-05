terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.25.0"
    }
  }
}

provider "azurerm" {
    features { }   
}

resource "azurerm_resource_group" "challenge_rg" {
    location = var.azure_region_name
    name = var.azure_resource_group_name
}

resource "azurerm_network_security_group" "vms_nsg" {
  location = azurerm_resource_group.challenge_rg.location
  name = var.network_security_group_name
  resource_group_name = azurerm_resource_group.challenge_rg.name
  
  
  security_rule {
    access = "Allow"
    description = "Allow 80 from everywhere"
    destination_address_prefix = "VirtualNetwork"
    destination_port_range = "80"
    direction = "Inbound"
    name = "web-all"
    priority = 100
    protocol = "*"
    source_address_prefix = "*"
    source_port_range = "*"
  }

  security_rule { 
    access = "Allow"
    description = "Allow 22 only"
    destination_address_prefix = "VirtualNetwork"
    destination_port_range = "22"
    direction = "Inbound"
    name = "ssh-cidr"
    priority = 101
    protocol = "Tcp"
    source_address_prefix = var.ssh_ip_or_cidr
    source_port_range = "*"
  }

}

resource "azurerm_virtual_network" "new_vnet" {
    address_space = [ var.azure_vnet_cidr ]
    location = azurerm_resource_group.challenge_rg.location
    name = var.azure_vnet_name
    resource_group_name = azurerm_resource_group.challenge_rg.name

    subnet {
      address_prefix = var.virtual_machines_snet_prefix
      name = var.virtual_machines_snet_name
      security_group = azurerm_network_security_group.vms_nsg.id
    }
}

resource "azurerm_managed_disk" "apache_data" {
  create_option = "Empty"
  location = azurerm_resource_group.challenge_rg.location
  name = "apache_data"
  resource_group_name = azurerm_resource_group.challenge_rg.name
  storage_account_type = "Premium_LRS"
  disk_size_gb = 32
  max_shares = 3

  lifecycle {
    prevent_destroy = true
  }
}

module "azurevms" {
  source = "./modules/vms"

  count = var.instance_count
  
  azure_region_name = azurerm_resource_group.challenge_rg.location
  azure_resource_group_name = azurerm_resource_group.challenge_rg.name
  azure_snet_id = one(azurerm_virtual_network.new_vnet.subnet[*].id)
  suffix = "${count.index}"
  key_path = var.key_path
  cert_path = var.cert_path
  vm_sku = var.vm_sku
}

resource "azurerm_virtual_machine_data_disk_attachment" "attachment" {
  count = var.instance_count
  
  managed_disk_id    = azurerm_managed_disk.apache_data.id
  virtual_machine_id = module.azurevms[count.index].vm_id
  lun                = "10"
  caching            = "None"

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u adminuser -i '${module.azurevms[count.index].vm_public_ip},' --private-key ${var.key_path} -e 'pub_key=${var.cert_path}' mount-disk-ubuntu.yml"
  }
}

module "azurelbs" {
  source = "./modules/lbs"
  
  azure_region_name = azurerm_resource_group.challenge_rg.location
  azure_resource_group_name = azurerm_resource_group.challenge_rg.name
  azure_snet_id = one(azurerm_virtual_network.new_vnet.subnet[*].id)
  frontend_ip_configuration_name = var.frontend_ip_configuration_name
}


resource "azurerm_lb_backend_address_pool" "lb_address_pool" {
    loadbalancer_id = module.azurelbs.lb_id
    name = "BackendAddressPool"
}

resource "azurerm_lb_backend_address_pool_address" "lb_address_pool_addresses" {
  count = var.instance_count

  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_address_pool.id
  virtual_network_id = azurerm_virtual_network.new_vnet.id
  name = "backendpooladdress${count.index}"
  ip_address = module.azurevms[count.index].vm_private_ip
}

resource "azurerm_lb_rule" "lb_rule" {
  backend_port = 80
  frontend_ip_configuration_name = var.frontend_ip_configuration_name
  frontend_port = 80
  loadbalancer_id = module.azurelbs.lb_id
  name = "lbRulePort80"
  protocol = "Tcp"
  backend_address_pool_ids = [ azurerm_lb_backend_address_pool.lb_address_pool.id ]
}