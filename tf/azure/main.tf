# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

# Create virtual network
resource "azurerm_virtual_network" "network" {
  name                = "${azurerm_resource_group.rg.name}-vnet"
  address_space       = ["${var.address_space}"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create install subnet
resource "azurerm_subnet" "subnet_install" {
  name                 = "${azurerm_virtual_network.network.name}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = ["${var.subnet_prefix}"]
}

resource "azurerm_public_ip" "public_ip" {
  name                = "public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# netif for install vm
resource "azurerm_network_interface" "nic_install" {
  name                = "${var.prefix}-nic-install"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.subnet_install.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
}

# Create virtual machine
resource "azurerm_virtual_machine" "vm_deploy" {
  name                  = "${var.prefix}-vm"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic_install.id]
  vm_size               = var.vm_size

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_os_disk {
    name              = "${var.prefix}-vm-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
  }

  storage_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  os_profile {
    computer_name  = "${var.prefix}-vm-deploy"
    admin_username = var.admin_username
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }
  
  tags = {
    environment = "Okd Deployent"
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${azurerm_resource_group.rg.name}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "ssh"
    priority                   = 101
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefixes    = var.ops_ips
    destination_port_range     = "22"
    destination_address_prefixes = azurerm_subnet.subnet_install.address_prefixes
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_binding" {
  subnet_id                 = azurerm_subnet.subnet_install.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet" "subnet_bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = ["${var.subnet_bastion_prefix}"]
}

resource "azurerm_public_ip" "okd_bastion_public_ip" {
  name                = "okd-bastion-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "okd_bastion" {
  name                = "okd-bastion"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.subnet_bastion.id
    public_ip_address_id = azurerm_public_ip.okd_bastion_public_ip.id
  }
}

resource "azurerm_network_security_group" "okd_install_nsg" {
  name                = "${azurerm_resource_group.rg.name}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "ssh"
    priority                   = 101
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefixes    = var.ops_ips
    destination_port_range     = "22"
    destination_address_prefixes = [azurerm_subnet.subnet_install.address_prefixes[0], azurerm_subnet.subnet_bastion.address_prefixes[0]]
  }
}

resource "azurerm_subnet_network_security_group_association" "okd_nsg_install_binding" {
  subnet_id                 = azurerm_subnet.subnet_install.id
  network_security_group_id = azurerm_network_security_group.okd_install_nsg.id
}
