# AWS
variable "aws_region" {
  type    = string
  default = "default"
}

# Snowflake
variable "snowflake_user" {
  type = string
}

variable "snowflake_password" {
  type      = string
  sensitive = true
}

variable "snowflake_account" {
  type = string
}

#Azure
variable "azure_tenant_id" {
  type = string
}

variable "azure_client_id" {
  type = string
}

variable "azure_client_secret" {
  type      = string
  sensitive = true
}