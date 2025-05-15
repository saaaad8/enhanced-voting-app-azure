terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "voting_app" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "voting_app" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.voting_app.location
  resource_group_name = azurerm_resource_group.voting_app.name
}

# Subnet
resource "azurerm_subnet" "voting_app" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.voting_app.name
  virtual_network_name = azurerm_virtual_network.voting_app.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "voting_app" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.voting_app.location
  resource_group_name = azurerm_resource_group.voting_app.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Vote-App"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Result-App"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8081"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# # Public IP
# Elastic Public IP
resource "azurerm_public_ip" "voting_app_elastic" {
  name                = "${var.prefix}-publicip-elastic"
  location            = azurerm_resource_group.voting_app.location
  resource_group_name = azurerm_resource_group.voting_app.name
  allocation_method   = "Static"
}

# Network Interface
resource "azurerm_network_interface" "voting_app" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.voting_app.location
  resource_group_name = azurerm_resource_group.voting_app.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.voting_app.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.voting_app_elastic.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "voting_app" {
  network_interface_id      = azurerm_network_interface.voting_app.id
  network_security_group_id = azurerm_network_security_group.voting_app.id
}

# Storage Account for VM diagnostics and persistent data
resource "azurerm_storage_account" "voting_app" {
  name                     = "${var.prefix}storage"
  resource_group_name      = azurerm_resource_group.voting_app.name
  location                 = azurerm_resource_group.voting_app.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Managed Disk for PostgreSQL data
resource "azurerm_managed_disk" "postgres_data" {
  name                 = "${var.prefix}-postgres-data-disk"
  location             = azurerm_resource_group.voting_app.location
  resource_group_name  = azurerm_resource_group.voting_app.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 2
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "voting_app" {
  name                = "${var.prefix}-vm"
  resource_group_name = azurerm_resource_group.voting_app.name
  location            = azurerm_resource_group.voting_app.location
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.voting_app.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.voting_app.primary_blob_endpoint
  }

  custom_data = base64encode(templatefile("${path.module}/cloud-init.tpl", {}))
}

# Attach the managed disk to the VM
resource "azurerm_virtual_machine_data_disk_attachment" "postgres_data" {
  managed_disk_id    = azurerm_managed_disk.postgres_data.id
  virtual_machine_id = azurerm_linux_virtual_machine.voting_app.id
  lun                = "10"
  caching            = "ReadWrite"
}

# Output the public IP address
output "public_ip_address" {
  value = azurerm_public_ip.voting_app_elastic.ip_address
  description = "The public IP address of the voting app VM"
}

output "ssh_command" {
  value = "ssh ${var.admin_username}@${azurerm_public_ip.voting_app_elastic.ip_address}"
  description = "Command to SSH into the VM"
}
