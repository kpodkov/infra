# terraform import snowflake_warehouse.compute_wh COMPUTE_WH
resource snowflake_warehouse compute_wh {
  name           = "COMPUTE_WH"
  warehouse_size = "X-Small"
  resource_monitor = snowflake_resource_monitor.compute_wh.name
}