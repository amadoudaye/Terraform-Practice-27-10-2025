apps = {
  "app1" = {
    os_type       = "Linux"
    sku_name      = "B1"
    runtime_stack = "NODE|18-lts"
    app_settings  = {
      "WEBSITE_RUN_FROM_PACKAGE" = "1"
    }
  }

  "app2" = {
    os_type       = "Windows"
    sku_name      = "B1"
    runtime_stack = "DOTNET|6.0"
    app_settings  = {
      "APPINSIGHTS_INSTRUMENTATIONKEY" = "xxxx-xxxx"
    }
  }
}
