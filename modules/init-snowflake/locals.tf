locals {
  config                  = jsondecode(file("${path.module}/tmp/config.json"))
  teams                   = flatten([for team in local.config["resources"]["teams"] : team])
  databases               = flatten([for team in local.teams : [for database in team["databases"] : database]])
  warehouses              = flatten([for team in local.teams : [for warehouse in team["warehouses"] : warehouse]])
  roles                   = concat(flatten([for team in local.teams : [for role in team["roles"] : role]]), [for role in local.config["global_resources"]["roles"] : role])
  role_grants             = local.config["role_grants"]
  database_grants         = {for db_grant in local.config["database_grants"] : db_grant["database_privilege"] => db_grant}
  warehouse_grants        = {for wh_grant in local.config["warehouse_grants"] : wh_grant["warehouse_privilege"] => wh_grant}
  resource_monitor_grants = {for rm_grant in local.config["resource_monitor_grants"] : rm_grant["resource_monitor_privilege"] => rm_grant}
  #  rsa_key_users                 = {for user in local.config["rsa_key_users"] : user["name"] => user}
  #  azure_application_assignments = {for app in local.config["azure_application_assignments"] : app["app_id"] => app}
}