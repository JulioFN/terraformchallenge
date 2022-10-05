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

variable "suffix" {
    type = string
    nullable = false
}

variable "cert_path"{
    type = string
    nullable = false
}

variable "key_path"{
    type = string
    nullable = false
}

variable "vm_sku" {
    type = string
    default = "Standard_D2as_v4"
}