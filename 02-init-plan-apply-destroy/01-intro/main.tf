# Terraform
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.40.0"
     }
  }
}

#Azure provider
provider "azurerm" {
  features {}
}

#create resource group
resource "azurerm_resource_group" "rgterraform_eg" {
    name     = "rg-terraexample"
    location = "westindia"
    tags      = {
      Environment = "terraexample"
    }
}

resource "azurerm_virtual_network" "virtualterraform"{
  name = "virtualterraform"
  location = azurerm_resource_group.rgterraform_eg.location
  resource_group_name = azurerm_resource_group.rgterraform_eg.name
  address_space = ["10.0.0.0/16", "10.0.1.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name = "subnet"
  resource_group_name = azurerm_resource_group.rgterraform_eg.name
  virtual_network_name = azurerm_virtual_network.virtualterraform.name
  address_prefixes = ["10.0.0.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name = "network-01-terraform-eg"
  resource_group_name = azurerm_resource_group.rgterraform_eg.name
  location = azurerm_resource_group.rgterraform_eg.location

  ip_configuration {
    name = "nicfg-terraform-eg"
    subnet_id = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
  }
  
}

resource "azurerm_windows_virtual_machine" "vm-terraform" {
  name = "vm-terraform"
  location = azurerm_resource_group.rgterraform_eg.location
  resource_group_name = azurerm_resource_group.rgterraform_eg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size = "Standard_B1s"
  admin_password = "P@ssWord123"
  admin_username = "terraadmin"

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}



