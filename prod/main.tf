module "aws" {
  source  = "../modules/init-snowflake"
  snowflake_account = var.snowflake_account
  snowflake_user = var.snowflake_user
  snowflake_password = var.snowflake_password
}

