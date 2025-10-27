# -----------------------------
# Core
# -----------------------------
resource "azurerm_resource_group" "rg" {
 name     = var.rg_name
 location = var.location
}
# Random suffix to avoid name clashes (web app names must be globally unique)
resource "random_string" "suffix" {
 length  = 5
 upper   = false
 lower   = true
 numeric = true
 special = false
}
# -----------------------------
# App Service Plans
# -----------------------------
resource "azurerm_service_plan" "plan_linux" {
 name                = "${var.project}-linux-plan"
 resource_group_name = azurerm_resource_group.rg.name
 location            = azurerm_resource_group.rg.location
 os_type  = "Linux"
 sku_name = var.plan_sku_linux # e.g., "P1v3" or "B1" or "S1"
}
resource "azurerm_service_plan" "plan_windows" {
 name                = "${var.project}-windows-plan"
 resource_group_name = azurerm_resource_group.rg.name
 location            = azurerm_resource_group.rg.location
 os_type  = "Windows"
 sku_name = var.plan_sku_windows # e.g., "P1v3" or "B1" or "S1"
}
# -----------------------------
# Application Insights (one per app)
# -----------------------------
resource "azurerm_application_insights" "ai_linux" {
 name                = "${var.project}-ai-linux-${random_string.suffix.result}"
 location            = azurerm_resource_group.rg.location
 resource_group_name = azurerm_resource_group.rg.name
 application_type    = "web"
}
resource "azurerm_application_insights" "ai_windows" {
 name                = "${var.project}-ai-windows-${random_string.suffix.result}"
 location            = azurerm_resource_group.rg.location
 resource_group_name = azurerm_resource_group.rg.name
 application_type    = "web"
}
# -----------------------------
# Linux Web App
# -----------------------------
resource "azurerm_linux_web_app" "app_linux" {
 name                = "${var.linux_app_name}-${random_string.suffix.result}"
 resource_group_name = azurerm_resource_group.rg.name
 location            = azurerm_resource_group.rg.location
 service_plan_id     = azurerm_service_plan.plan_linux.id
 https_only          = true
 site_config {
   minimum_tls_version = "1.2"
   ftps_state          = "Disabled"
   # Choose ONE of the two stacks below.
   # 1) Built-in runtime (comment out the docker block if using this):
   application_stack {
     # Examples: "18-lts", "20-lts"
     node_version = var.linux_node_version
     # Alternatively: dotnet_version = "7.0"
     # Or:          python_version = "3.10"
     # Or:          php_version    = "8.2"
   }
   # 2) Docker container (uncomment to use a custom image instead)
   # application_stack {
   #   docker_image_name   = var.linux_docker_image_name   # e.g., "mcr.microsoft.com/azuredocs/aci-helloworld"
   #   docker_registry_url = var.linux_docker_registry_url # e.g., "https://index.docker.io"
   # }
 }
 app_settings = merge(
   var.common_app_settings,
   {
     "WEBSITE_RUN_FROM_PACKAGE"          = "0"
     "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
     "APPINSIGHTS_INSTRUMENTATIONKEY"    = azurerm_application_insights.ai_linux.instrumentation_key
     "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.ai_linux.connection_string
     "ASPNETCORE_ENVIRONMENT"            = var.environment
   },
   var.linux_app_settings
 )
 identity {
   type = "SystemAssigned"
 }
 lifecycle {
   ignore_changes = [
     app_settings["WEBSITE_RUN_FROM_PACKAGE"]
   ]
 }
}
# Optional: Linux staging slot (enable if you want blue/green)
# resource "azurerm_linux_web_app_slot" "slot_linux" {
#   name           = "staging"
#   app_service_id = azurerm_linux_web_app.app_linux.id
#   site_config { minimum_tls_version = "1.2" }
#   app_settings = { "SLOT" = "staging" }
# }
# -----------------------------
# Windows Web App
# -----------------------------
resource "azurerm_windows_web_app" "app_windows" {
 name                = "${var.windows_app_name}-${random_string.suffix.result}"
 resource_group_name = azurerm_resource_group.rg.name
 location            = azurerm_resource_group.rg.location
 service_plan_id     = azurerm_service_plan.plan_windows.id
 https_only          = true
 site_config {
   minimum_tls_version = "1.2"
   ftps_state          = "Disabled"
   # .NET on Windows (Framework or Core)
   application_stack {
     current_stack  = "dotnet"         # other options include: "node", "java", "python", "php"
     dotnet_version = var.windows_dotnet_version  # e.g., "v6.0", "v7.0"
   }
   # For Node on Windows instead, use:
   # application_stack {
   #   current_stack = "node"
   #   node_version  = "18-LTS"
   # }
 }
 app_settings = merge(
   var.common_app_settings,
   {
     "APPINSIGHTS_INSTRUMENTATIONKEY"       = azurerm_application_insights.ai_windows.instrumentation_key
     "APPLICATIONINSIGHTS_CONNECTION_STRING"= azurerm_application_insights.ai_windows.connection_string
     "WEBSITE_HTTPLOGGING_RETENTION_DAYS"   = "7"
     "ASPNETCORE_ENVIRONMENT"               = var.environment
   },
   var.windows_app_settings
 )
 identity {
   type = "SystemAssigned"
 }
}
# Optional: Windows staging slot
# resource "azurerm_windows_web_app_slot" "slot_windows" {
#   name           = "staging"
#   app_service_id = azurerm_windows_web_app.app_windows.id
#   site_config { minimum_tls_version = "1.2" }
#   app_settings = { "SLOT" = "staging" }
# }
# -----------------------------
# Outputs
# -----------------------------
output "linux_web_app_name" {
 value = azurerm_linux_web_app.app_linux.name
}
output "linux_web_app_url" {
 value = "https://${azurerm_linux_web_app.app_linux.default_hostname}"
}
output "windows_web_app_name" {
 value = azurerm_windows_web_app.app_windows.name
}
output "windows_web_app_url" {
 value = "https://${azurerm_windows_web_app.app_windows.default_hostname}"
