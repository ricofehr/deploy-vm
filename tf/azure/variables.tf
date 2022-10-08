
variable "vm_size" {
  default = "Standard_D2_v2"
}

variable "prefix" {
  default = "bootstrap"
}

variable "location" {
  default     = "northeurope"
  description = "Location of the resource group."
}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.50.10.0/24"
}

variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.50.10.0/26"
}

variable "subnet_bastion_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.50.10.64/26"
}

variable "admin_username" {
  description = "Linux administrator name"
  default     = "sysadmin"
}

variable "image_publisher" {
  description = "Image Publisher"
  default     = "Canonical"
}

variable "image_offer" {
  description = "Image Offer"
  default     = "0001-com-ubuntu-minimal-jammy"
}

variable "image_sku" {
  description = "Image Sku"
  default     = "minimal-22_04-lts"
}

variable "image_version" {
  description = "Image Version"
  default     = "22.04.202207180"
}

variable "ops_ips" {
  description = "Sysops ips for deployment and support purposes"
}

