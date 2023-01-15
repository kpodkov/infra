resource snowflake_database db {
  for_each = {for database in local.databases : database["name"] => database}
  name     = each.key
  #  tag {
  #    name  = each.value["tags"]["name"]
  #    value = each.value["tags"]["value"]
  #  }
  #
  #  lifecycle {
  #    prevent_destroy = true
  #  }
}

resource snowflake_warehouse wh {
  for_each            = {for warehouse in local.warehouses : warehouse["name"] => warehouse}
  name                = each.key
  warehouse_size      = "XSMALL"
  auto_resume         = true
  initially_suspended = true
  auto_suspend        = each.value["auto_suspend"]
  resource_monitor    = snowflake_resource_monitor.monitor[each.key].name
  lifecycle {
    ignore_changes = [
      warehouse_size,
      statement_timeout_in_seconds,
      min_cluster_count,
      max_cluster_count,
    ]
  }
}

resource snowflake_resource_monitor monitor {
  for_each        = {for warehouse in local.warehouses : warehouse["name"] => warehouse}
  name            = upper(each.value["resource_monitor"])
  credit_quota    = each.value["quota"]
  frequency       = "WEEKLY"
  start_timestamp = "IMMEDIATELY"
  notify_triggers = [
    85
  ]
  suspend_triggers = [
    95
  ]
  suspend_immediate_triggers = [
    100
  ]
  lifecycle {
    ignore_changes = [
      credit_quota,
      frequency,
      start_timestamp,
      notify_triggers,
      suspend_triggers,
      suspend_immediate_triggers,
      frequency,
      start_timestamp,
    ]
  }
}

resource "snowflake_role" "role" {
  for_each = {for role in local.roles : role["name"] => role}
  name     = each.key
  comment  = each.value["comment"]
}