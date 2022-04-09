locals {
  config                        = jsondecode(file("${path.module}/tmp/config.json"))
  databases                     = toset(local.config["resources"]["databases"])
  teams                         = toset([for team in local.config["resources"]["teams"] : team["name"]])
  warehouses                    = toset([for warehouse in local.config["resources"]["warehouses"] : warehouse["name"]])
  resource_monitors             = toset([for warehouse in local.config["resources"]["warehouses"] : warehouse["resource_monitor"]])
  quotas                        = {for warehouse in local.config["resources"]["warehouses"] : warehouse["resource_monitor"] => warehouse["quota"]}
  auto_suspends                 = {for warehouse in local.config["resources"]["warehouses"] : warehouse["name"] => warehouse["auto_suspend"]}
  roles                         = merge({for role in local.config["resources"]["roles"] : role["name"] => role}, {for role in local.config["global_resources"]["roles"] : role["name"] => role})
  role_grants                   = local.config["role_grants"]
  database_grants               = {for db_grant in local.config["database_grants"] : db_grant["database_privilege"] => db_grant}
  warehouse_grants              = {for wh_grant in local.config["warehouse_grants"] : wh_grant["warehouse_privilege"] => wh_grant}
  resource_monitor_grants       = {for rm_grant in local.config["resource_monitor_grants"] : rm_grant["resource_monitor_privilege"] => rm_grant}
  rsa_key_users                 = {for user in local.config["rsa_key_users"] : user["name"] => user}
  azure_application_assignments = {for app in local.config["azure_application_assignments"] : app["app_id"] => app}
}