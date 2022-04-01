# Pre-requisites

- terraform

# Initial Snowflake Setup

1. Initialize and run terraform to create the necessary resources:

```shell
export AWS_PROFILE="terraform"

cd init-snowflake/
terraform init
terraform apply
```