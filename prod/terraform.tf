terraform {
  required_version = "~> 1.1.0"

  backend "s3" {
    bucket = "tfstate-731310336214"
    key    = "init-snowflake/prod/terraform.tfstate"
    region = "eu-central-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.8.0"
    }
    snowflake = {
      source  = "chanzuckerberg/snowflake"
      version = "0.29.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

provider snowflake {
  username = var.snowflake_user
  password = var.snowflake_password
  account  = var.snowflake_account
  role     = "ACCOUNTADMIN"
}