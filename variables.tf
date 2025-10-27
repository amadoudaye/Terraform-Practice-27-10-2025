variable "apps" {
  description = "Map of web apps to create"
  type = map(object({
    os_type        = string
    sku_name       = string
    runtime_stack  = string
    app_settings   = map(string)
  }))
}
