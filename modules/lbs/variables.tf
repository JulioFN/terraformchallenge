variable "azure_region_name" {
    description = "Azure Region"
    type = string
    nullable = false
}

variable "azure_resource_group_name" {
    type = string
    nullable = false
}

variable "azure_snet_id" {
    type = string
    nullable = false
}

variable "frontend_ip_configuration_name" {
    type = string
    nullable = false
}