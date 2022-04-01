terraform {

  backend "s3" {
    bucket = "tfstate-731310336214"
    key    = "{$environment}/snowflake-infra/terraform.tfstate"
    region = "eu-central-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.19.1"
    }
    snowflake = {
      source  = "chanzuckerberg/snowflake"
      version = "0.29.0"
    }
  }
  required_version = ">= 0.14.9"
}