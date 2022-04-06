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
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.19.1"
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

provider "azuread" {
  tenant_id = var.azure_tenant_id
  client_id = var.azure_client_id
  client_secret = var.azure_client_secret
}

provider "tls" {
  # Configuration options
}
