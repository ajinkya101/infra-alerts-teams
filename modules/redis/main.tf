# ---------------------------
# Create Azure Redis Service
# ---------------------------
resource "azurerm_redis_cache" "redis" {
  name                = var.redis_name
  resource_group_name = var.rg_name
  location            = var.location

  family   = var.redis_family
  sku_name = var.sku_name
  capacity = var.capacity

  enable_non_ssl_port = var.allow_non_ssl_connections
  minimum_tls_version = var.minimum_tls_version

  zones                     = var.sku_name == "Premium" ? var.availability_zones : null
  private_static_ip_address = var.sku_name == "Premium" ? var.private_static_ip_address : null
  subnet_id                 = var.sku_name == "Premium" ? var.subnet_id : null
  shard_count               = var.sku_name == "Premium" ? var.cluster_shard_count : 0

  tags = merge({ "Name" = format("%s", var.redis_name) }, var.tags, )

  redis_configuration {
    enable_authentication           = lookup(var.redis_configuration, "enable_authentication", null)
    maxfragmentationmemory_reserved = lookup(var.redis_configuration, "maxfragmentationmemory_reserved", null)
    maxmemory_delta                 = lookup(var.redis_configuration, "maxmemory_delta", null)
    maxmemory_policy                = lookup(var.redis_configuration, "maxmemory_policy", null)
    maxmemory_reserved              = lookup(var.redis_configuration, "maxmemory_reserved", null)
    notify_keyspace_events          = lookup(var.redis_configuration, "notify_keyspace_events", null)
  }

  lifecycle {
    ignore_changes = [redis_configuration[0].rdb_storage_connection_string]
  }
}

#----------------------------------------------------------------
# Create a log analytics workspace for azure redis cache
#----------------------------------------------------------------
resource "azurerm_log_analytics_workspace" "logws" {
  count               = var.enable_log_analytics_workspace ? 1 : 0
  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = var.log_retention_in_days

  tags = merge({ "Name" = format("%s", var.log_analytics_workspace_name) }, var.tags, )
}

#------------------------------------------------------------------
# azurerm monitoring diagnostics  - Default is "false" 
#------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "extaudit" {
  count                      = var.log_analytics_workspace_name != null ? 1 : 0
  name                       = "extaudit-${var.redis_name}-diag"
  target_resource_id         = azurerm_redis_cache.redis.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logws.0.id

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
      days    = "30"
    }
  }

  lifecycle {
    ignore_changes = [metric]
  }
}