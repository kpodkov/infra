resource snowflake_resource_monitor compute_wh {
  name            = "COMPUTE_WH"
  credit_quota    = 10
  start_timestamp = "IMMEDIATELY"
  frequency       = "WEEKLY"

  notify_triggers            = [40]
  suspend_triggers           = [50]
  suspend_immediate_triggers = [90]
  lifecycle {
    ignore_changes = [start_timestamp]
  }
}