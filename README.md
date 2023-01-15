# infra

# Table of Contents

- [Running Locally](#running-locally)
- [Modules](#modules)
    * [init-aws](#init-aws)
    * [init-snowflake](#init-snowflake)
- [AZ Login](#az-login)

# Running Locally

```shell
export WORKDIR="prod/aws"
bin/terraform init
bin/terraform plan

export WORKDIR="prod/snowflake"
bin/terraform init
bin/terraform plan

# Makefile Targets 
docker-build: docker-build
plan: clean init generate-config
apply: plan
```

⚠ `make apply` will automatically approve ⚠

# Modules

## init-aws

This module initializes resources required by terraform on AWS: assumable role, an s3 bucket, and a dynamodb table.

## init-snowflake

This module initializes Snowflake resources based on configuration yaml in `config/snowflake/<team>.yaml`.

# AZ Login

```shell
az login --service-principal --username $TF_VAR_azure_client_id --password $TF_VAR_azure_client_secret --tenant $TF_VAR_azure_tenant_id
az login --service-principal --username $AZURE_CLIENT_ID --password $AZURE_SECRET --tenant $AZURE_TENANT_ID
```
