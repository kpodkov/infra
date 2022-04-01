terraform {
  required_version = "~> 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.8.0"
    }
    #    azuread = {
    #      source  = "hashicorp/azuread"
    #      version = "2.19.1"
    #    }
    snowflake = {
      source  = "chanzuckerberg/snowflake"
      version = "0.29.0"
    }
  }
}