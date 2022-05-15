#----------------------------------------------------------------
# Create Logic app to post alerts to slack channel
#----------------------------------------------------------------
resource "azurerm_logic_app_workflow" "logicapp" {
  name                = var.logicapp_name
  location            = var.location
  resource_group_name = var.rg_name

  lifecycle {
    ignore_changes = [
      # Ignore changes to parameters as otherwise we will break the $connections
      parameters,
      workflow_parameters,
      tags
    ]
  }
}

#-------------------------------------------------------------------
# Deploy the ARM template to configure the workflow in the logicapp
#-------------------------------------------------------------------
locals {
  arm_file_path = "${path.module}/la_workflow.json"
}

data "template_file" "workflow" {
  template = file(local.arm_file_path)
}

resource "azurerm_resource_group_template_deployment" "workflow" {
  name                = "workflow-${filemd5(local.arm_file_path)}"
  resource_group_name = var.rg_name
  deployment_mode     = "Incremental"
  parameters_content = jsonencode({
    "logicAppName" = {
      value = var.logicapp_name
    },
    "msTeamId" = {
      value = var.msTeamId
    },
    "msTeamChannelId" = {
      value = var.msTeamChannelId
    },
    "resourceTags" = {
      value = merge({ "Name" = format("%s", var.logicapp_name) }, var.tags, )
    }
  })
  template_content = data.template_file.workflow.template

  depends_on = [azurerm_logic_app_workflow.logicapp]
}

#----------------------------------------------------------------
# Setup Action Group to notify Users about Redis Insights alerts
#----------------------------------------------------------------
resource "azurerm_monitor_action_group" "redis-alert-Teams" {
  name                = "MSTeams-alerts-${var.redis_release}"
  resource_group_name = var.rg_name
  short_name          = "Webhook"

  webhook_receiver {
    name                    = "callmylogicapp"
    service_uri             = jsondecode(azurerm_resource_group_template_deployment.workflow.output_content).endpointUrl.value
    use_common_alert_schema = false
  }
}

#----------------------------------------------------------------
# Setup Action Group to notify when logic apps run failed.
#----------------------------------------------------------------
resource "azurerm_monitor_action_group" "email" {
  name                = "Email Desk-${var.redis_release}"
  resource_group_name = var.rg_name
  short_name          = "Email"

  email_receiver {
    name                    = "Email"
    email_address           = var.ag_email
    use_common_alert_schema = true
  }
}

#----------------------------------------------------------------
# Enable alerts on Azure Logic apps Run failed
#----------------------------------------------------------------
resource "azurerm_monitor_metric_alert" "laralert" {
  name                 = "${var.redis_release}-runs-metricalert"
  resource_group_name  = var.rg_name
  scopes               = [azurerm_logic_app_workflow.logicapp.id]
  description          = "This alert will be triggered when Runs failed in Logic apps"
  target_resource_type = "Microsoft.Logic/workflows"

  criteria {
    metric_namespace = "Microsoft.Logic/workflows"
    metric_name      = "RunsFailed"
    aggregation      = "Count"
    operator         = "GreaterThanOrEqual"
    threshold        = 1
  }

  action {
    action_group_id = azurerm_monitor_action_group.email.id
  }
}


#----------------------------------------------------------------
# Enable alerts on Azure Redis for CPU Usage above 90%
#----------------------------------------------------------------
resource "azurerm_monitor_metric_alert" "lscpalert" {
  name                 = "${var.redis_release}-cpu-metricalert"
  resource_group_name  = var.rg_name
  scopes               = [azurerm_redis_cache.redis.id]
  description          = "This alert will be triggered when CPU Percentage reach above 90 Percentage for Azure Redis Cache Instance"
  target_resource_type = "Microsoft.Cache/redis"

  criteria {
    metric_namespace = "Microsoft.Cache/redis"
    metric_name      = "percentProcessorTime"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 90
  }

  action {
    action_group_id = azurerm_monitor_action_group.redis-alert-Teams.id
  }
}

#----------------------------------------------------------------
# Enable alerts on Azure Redis for Memory Usage above 90%
#----------------------------------------------------------------
resource "azurerm_monitor_metric_alert" "lsmemalert" {
  name                 = "${var.redis_release}-mem-metricalert"
  resource_group_name  = var.rg_name
  scopes               = [azurerm_redis_cache.redis.id]
  description          = "This alert will be triggered when Memory Usage Percentage reach above 90 Percentage for Azure Redis Cache Instance"
  target_resource_type = "Microsoft.Cache/redis"

  criteria {
    metric_namespace = "Microsoft.Cache/redis"
    metric_name      = "usedmemorypercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 90
  }

  action {
    action_group_id = azurerm_monitor_action_group.redis-alert-Teams.id
  }
}