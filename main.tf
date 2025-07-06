provider "azurerm" {
  features {}
  subscription_id                  = "2213e8b1-dbc7-4d54-8aff-b5e315df5e5b"
  resource_provider_registrations = "none"
}

variable "admin_password" {
  type        = string
  sensitive   = true
  description = "Admin password for the Windows VM"
  default     = "Password1234!" # Replace in real use
}

locals {
  rg_name   = "1-98223ae7-playground-sandbox"
  rg_region = "westus"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "lab-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = local.rg_region
  resource_group_name = local.rg_name

  tags = {
    environment = "sandbox"
    owner       = "kumar"
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "lab-subnet"
  resource_group_name  = local.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "lab-nic"
  location            = local.rg_region
  resource_group_name = local.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                  = "lab-winvm"
  resource_group_name   = local.rg_name
  location              = local.rg_region
  size                  = "Standard_B2s"
  admin_username        = "azureuser"
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  tags = {
    environment = "sandbox"
    owner       = "kumar"
  }
}
