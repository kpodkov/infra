terraform {
  required_version = "~> 1.1.0"

  required_providers {
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