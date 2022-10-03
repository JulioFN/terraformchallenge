variable "azure_region_name" {
    description = "Azure Region"
    type = string
    default = "eastus"
}

variable "azure_resource_group_name" {
    type = string
    default = "challenge-rg"
}

variable "azure_vnet_name" {
    type = string
    default = "challenge-vnet"
}

variable "azure_vnet_cidr" {
    type = string
    default = "10.0.0.0/8"
}

variable "virtual_machines_snet_name" {
    type = string
    default = "machines_snet"
}

variable "virtual_machines_snet_prefix" {
    type = string
    default = "10.0.0.0/16"
}

variable "network_security_group_name" {
    type = string
    default = "web-nsg"
}

variable "instance_count" {
  description = "Number of instances to provision."
  type        = number
  default     = 3
}

variable "key_path" {
    description = "The path to a key file for the admin user created on provisioned machines."
    type = string
    default = "./id_rsa.pub"
}

variable "frontend_ip_configuration_name" {
    type = string
    default = "InternalIP"
}