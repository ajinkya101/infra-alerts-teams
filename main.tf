# Configure the Microsoft Azure Provider
provider "azurerm" {
  # skip_provider_registration = true
  features {}
}

module "rg1" {
  source     = "./modules/rg"
  az_rg_name = "testrg1"
  tags = {
    "env"    = "dev",
    "region" = "eastus"
  }
}

module "demoredis" {
  source  = "./modules/redis"
  rg_name = module.rg1.rg_name

  # Require Redis Configuration
  redis_name                = "demoredissvc"
  sku_name                  = "Standard"
  redis_family              = "C"
  capacity                  = "1"
  allow_non_ssl_connections = true

  enable_log_analytics_workspace = true
  log_analytics_workspace_name   = "demoredissvclaw"

  #Logic app inputs
  msTeamId        = "4dbebb37-c017-4483-aa8b-26d4a01b4de8"
  msTeamChannelId = "19%3aKsrELenmjB3PYM6jgWbk9nu5J_e191NOoZoIC9vwHbk1%40thread.tacv2"

  tags = {
    "env"    = "dev",
    "region" = "eastus"
  }
}