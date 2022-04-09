resource snowflake_database db {
  for_each = local.databases
  name     = each.key
  lifecycle {
    prevent_destroy = true
  }
}

resource snowflake_warehouse wh {
  for_each            = local.warehouses
  name                = each.key
  warehouse_size      = "XSMALL"
  auto_resume         = true
  initially_suspended = true
  auto_suspend        = local.auto_suspends[each.key]
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
  for_each        = local.resource_monitors
  name            = upper(each.key)
  credit_quota    = local.quotas[each.key]
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
  for_each = local.roles
  name     = each.key
  comment  = local.roles[each.key]["comment"]
}