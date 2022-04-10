module "init-snowflake" {
  source     = "../modules/init-snowflake"
}

output "debug" {
  value = module.init-snowflake.debug
}