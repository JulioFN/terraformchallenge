resource "azurerm_network_interface" "nic" {
  name                = "vmnic${var.suffix}"
  location            = var.azure_region_name
  resource_group_name = var.azure_resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.azure_snet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "virtualmachine${var.suffix}"
  resource_group_name = var.azure_resource_group_name
  location            = var.azure_region_name
  size                = "Standard_D2as_v4"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file(var.key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}


resource "azurerm_virtual_machine_data_disk_attachment" "attachment" {
  managed_disk_id    = var.disk_id_to_attach
  virtual_machine_id = azurerm_linux_virtual_machine.vm.id
  lun                = "10"
  caching            = "ReadWrite"
}