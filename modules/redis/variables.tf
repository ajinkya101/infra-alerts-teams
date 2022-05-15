variable "rg_name" {
  description = "Name of an Resource Group"
}

variable "location" {
  description = "Azure location for deployment"
  default     = "eastus"
}

variable "redis_name" {
  description = "Name of redis server"
  type        = string
  default     = ""
}

variable "redis_family" {
  type        = string
  description = "Redis family value.It can be C, P"
  default     = "C"
}

variable "sku_name" {
  description = "Redis Cache Sku Value. It Can be Basic, Standard or Premium"
  type        = string
  default     = "Standard"
}

variable "availability_zones" {
  description = "Availability zones used for deployment of Redis Service."
  default     = ["1", "2"]
}

variable "allow_non_ssl_connections" {
  description = "Activate non SSL port (6779) for Redis connection"
  type        = bool
  default     = false
}

variable "minimum_tls_version" {
  description = "The minimum TLS version"
  type        = string
  default     = "1.2"
}

variable "cluster_shard_count" {
  description = "Number of cluster shards desired"
  type        = number
  default     = 3
}

variable "capacity" {
  description = "Redis size: (Basic/Standard: 1,2,3,4,5,6) (Premium: 1,2,3,4)  https://docs.microsoft.com/fr-fr/azure/redis-cache/cache-how-to-premium-clustering"
  type        = number
  default     = 2
}

variable "private_static_ip_address" {
  description = "The Static IP Address to assign to the Redis Cache when hosted inside the Virtual Network. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "The ID of the Subnet within which the Redis Cache should be deployed. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "redis_configuration" {
  description = "Configuration for the Redis instance. Some of the keys are set automatically. See https://www.terraform.io/docs/providers/azurerm/r/redis_cache.html#redis_configuration for full reference."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_log_analytics_workspace" {
  type        = bool
  description = "Enable the creation of azurerm_log_analytics_workspace and azurerm_log_analytics_solution or not"
  default     = false
}

variable "log_analytics_workspace_name" {
  type        = string
  description = "The name of the Analytics workspace"
  default     = null
}

variable "log_analytics_workspace_sku" {
  description = "The SKU (pricing level) of the Log Analytics workspace. For new subscriptions the SKU should be set to PerGB2018"
  type        = string
  default     = "PerGB2018"
}

variable "log_retention_in_days" {
  description = "The retention period for the logs in days"
  type        = number
  default     = 30
}

variable "ag_email" {
  description = "Email id used to notify user about alerts"
  default     = "bhabalajinkya@yandex.com"
}

variable "redis_release" {
  type        = string
  description = "Redis Release Number to identify deployment in alerts"
  default     = "demoredissvc"
}

variable "logicapp_name" {
  type        = string
  description = "Name of logic app resource"
  default     = "demoredissvcla"
}

variable "msTeamId" {
  type        = string
  description = "Name of slack channel where alerts will be posted."
  default     = ""
}

variable "msTeamChannelId" {
  type        = string
  description = "Name of slack channel where alerts will be posted."
  default     = ""
}