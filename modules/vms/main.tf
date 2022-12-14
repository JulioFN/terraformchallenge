resource "azurerm_public_ip" "public_ip" {
  name                = "VMPublicIp${var.suffix}"
  location            = var.azure_region_name
  resource_group_name = var.azure_resource_group_name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  name                = "vmnic${var.suffix}"
  location            = var.azure_region_name
  resource_group_name = var.azure_resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.azure_snet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "virtualmachine${var.suffix}"
  resource_group_name = var.azure_resource_group_name
  location            = var.azure_region_name
  size                = var.vm_sku
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file(var.cert_path)
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

  provisioner "remote-exec" {
    inline = ["sudo sed -i 's/#$nrconf{restart} = '\"'\"'i'\"'\"';/$nrconf{restart} = '\"'\"'a'\"'\"';/g' /etc/needrestart/needrestart.conf", "sudo apt-get update", "sudo apt-get install python3 -y", "echo Done!"]

    connection {
      host        = azurerm_public_ip.public_ip.ip_address
      type        = "ssh"
      user        = "adminuser"
      private_key = file(var.key_path)
    }
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u adminuser -i '${azurerm_public_ip.public_ip.ip_address},' --private-key ${var.key_path} -e 'pub_key=${var.cert_path}' ${path.module}/install-apache.yml"
  }
}