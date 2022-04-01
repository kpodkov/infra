resource snowflake_resource_monitor compute_wh {
  name         = "COMPUTE_WH"
  credit_quota = 10
  start_timestamp = "2022-03-29 00:00"
  frequency    = "WEEKLY"

  notify_triggers            = [40]
  suspend_triggers           = [50]
  suspend_immediate_triggers = [90]
}