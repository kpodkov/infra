#+-+-+-+-+-+-+-+-+-+-+
#|R|o|l|e|G|r|a|n|t|s|
#+-+-+-+-+-+-+-+-+-+-+
resource snowflake_role_grants role_grant {
  for_each  = local.role_grants
  role_name = snowflake_role.role[each.key].name
  roles     = each.value
  lifecycle {
    ignore_changes = [
      users
    ]
  }
  depends_on = [
    snowflake_role.role
  ]
}

#+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#|D|a|t|a|b|a|s|e|G|r|a|n|t|s|
#+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
resource snowflake_database_grant db_usage_grant {
  for_each          = snowflake_database.db
  database_name     = each.value.name
  privilege         = "USAGE"
  roles             = local.database_grants["${each.key}_USAGE"]["roles"]
  with_grant_option = local.database_grants["${each.key}_USAGE"]["with_grant_option"]
  lifecycle {
    ignore_changes = [
      roles,
    ]
  }
  depends_on = [
    snowflake_role.role
  ]
}

resource snowflake_database_grant db_monitor_grant {
  for_each          = snowflake_database.db
  database_name     = each.value.name
  privilege         = "MONITOR"
  roles             = local.database_grants["${each.key}_MONITOR"]["roles"]
  with_grant_option = local.database_grants["${each.key}_MONITOR"]["with_grant_option"]
  lifecycle {
    ignore_changes = [
      roles,
    ]
  }
  depends_on = [
    snowflake_role.role
  ]
}

resource snowflake_database_grant db_create_schema_grant {
  for_each          = snowflake_database.db
  database_name     = each.value.name
  privilege         = "CREATE SCHEMA"
  roles             = local.database_grants["${each.key}_CREATE_SCHEMA"]["roles"]
  with_grant_option = local.database_grants["${each.key}_CREATE_SCHEMA"]["with_grant_option"]
  lifecycle {
    ignore_changes = [
      roles,
    ]
  }
  depends_on = [
    snowflake_role.role
  ]
}

#+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#|W|a|r|e|h|o|u|s|e|G|r|a|n|t|s|
#+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
resource snowflake_warehouse_grant wh_operate_grant {
  for_each          = snowflake_warehouse.wh
  warehouse_name    = each.value.name
  privilege         = "OPERATE"
  roles             = local.warehouse_grants["${each.key}_OPERATE"]["roles"]
  with_grant_option = local.warehouse_grants["${each.key}_OPERATE"]["with_grant_option"]
  depends_on        = [
    snowflake_role.role
  ]
}

resource snowflake_warehouse_grant wh_monitor_grant {
  for_each          = snowflake_warehouse.wh
  warehouse_name    = each.value.name
  privilege         = "MONITOR"
  roles             = local.warehouse_grants["${each.key}_MONITOR"]["roles"]
  with_grant_option = local.warehouse_grants["${each.key}_MONITOR"]["with_grant_option"]
  depends_on        = [
    snowflake_role.role
  ]
}

resource snowflake_warehouse_grant wh_modify_grant {
  for_each          = snowflake_warehouse.wh
  warehouse_name    = each.value.name
  privilege         = "MODIFY"
  roles             = local.warehouse_grants["${each.key}_MODIFY"]["roles"]
  with_grant_option = local.warehouse_grants["${each.key}_MODIFY"]["with_grant_option"]
  depends_on        = [
    snowflake_role.role
  ]
}

resource snowflake_warehouse_grant wh_usage_grant {
  for_each          = snowflake_warehouse.wh
  warehouse_name    = each.value.name
  privilege         = "USAGE"
  roles             = local.warehouse_grants["${each.key}_USAGE"]["roles"]
  with_grant_option = local.warehouse_grants["${each.key}_USAGE"]["with_grant_option"]
  depends_on        = [
    snowflake_role.role
  ]
}

#+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#|R|e|s|o|u|r|c|e|M|o|n|i|t|o|r|G|r|a|n|t|
#+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
resource snowflake_resource_monitor_grant resource_monitor_grant {
  for_each          = snowflake_resource_monitor.monitor
  monitor_name      = each.key
  privilege         = "MONITOR"
  roles             = local.resource_monitor_grants["${each.key}_MONITOR"]["roles"]
  with_grant_option = local.resource_monitor_grants["${each.key}_MONITOR"]["with_grant_option"]
  depends_on        = [
    snowflake_role.role
  ]
}