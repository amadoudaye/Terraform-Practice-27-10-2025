terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  required_version = ">= 1.3.0"
}

# -----------------------------
# Provider Configuration
# -----------------------------
provider "azurerm" {
  features {}
}

# -----------------------------
# Resource Group
# -----------------------------
resource "azurerm_resource_group" "rg" {
  name     = "rg-webapps-foreach"
  location = "Canada Central"
}

# -----------------------------
# App Service Plans
# -----------------------------
resource "azurerm_service_plan" "plan" {
  for_each = var.apps

  name                = "${each.key}-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = each.value.os_type
  sku_name            = each.value.sku_name
}

# -----------------------------
# Linux Web Apps
# -----------------------------
resource "azurerm_linux_web_app" "linux" {
  for_each = {
    for name, cfg in var.apps : name => cfg if cfg.os_type == "Linux"
  }

  name                = "${each.key}-linux"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan[each.key].id

  site_config {
    application_stack {
      node_version   = try(regex("^NODE\\|(.*)$", each.value.runtime_stack)[0], null)
      python_version = try(regex("^PYTHON\\|(.*)$", each.value.runtime_stack)[0], null)
      dotnet_version = try(regex("^DOTNET\\|(.*)$", each.value.runtime_stack)[0], null)
    }
  }

  app_settings = each.value.app_settings
}

# -----------------------------
# Windows Web Apps
# -----------------------------
resource "azurerm_windows_web_app" "windows" {
  for_each = {
    for name, cfg in var.apps : name => cfg if cfg.os_type == "Windows"
  }

  name                = "${each.key}-win"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan[each.key].id

  site_config {
    application_stack {
      current_stack  = split("|", each.value.runtime_stack)[0]
      dotnet_version = try(regex("^DOTNET\\|(.*)$", each.value.runtime_stack)[0], null)
      node_version   = try(regex("^NODE\\|(.*)$", each.value.runtime_stack)[0], null)
    }
  }

  app_settings = each.value.app_settings
}

# -----------------------------
# Output Web App URLs
# -----------------------------
output "app_urls" {
  value = merge(
    { for k, v in azurerm_linux_web_app.linux   : k => v.default_hostname },
    { for k, v in azurerm_windows_web_app.windows: k => v.default_hostname }
  )
}
