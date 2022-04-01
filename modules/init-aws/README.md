# Pre-requisites

- terraform
- jq
- aws-cli

# Initial AWS Setup for Terraform

1. Add the default AWS profile:

```shell
user@local: aws configure

AWS Access Key ID [None]: 
AWS Secret Access Key [None]: 
Default region name [None]: 
Default output format [None]: 
```

2. Initialize and run terraform to create necessary resources:

```shell
cd init-aws/
terraform init
terraform apply
```

3. Configure the `terraform` profile. Get the credentials from `terraform.tfstate`:

```shell
user@local: aws --profile terraform configure

AWS Access Key ID [None]: 
AWS Secret Access Key [None]: 
Default region name [None]: 
Default output format [None]: 
```

4. Configure the `terraform` profile using credentials from the assumed role:

```shell
AWS_ACCOUNT_ID=731310336214

# Assume a role using STS and save the credentials to a local AWS Profile
eval $(aws sts assume-role \
  --role-arn "arn:aws:iam::$AWS_ACCOUNT_ID:role/TerraformRole" \
  --role-session-name "terraform-session" | \
  jq --arg profile "terraform" -r '.Credentials | @sh "aws --profile \($profile) configure set aws_access_key_id \(.AccessKeyId) && aws --profile \($profile) configure set aws_secret_access_key \(.SecretAccessKey)  && aws --profile \($profile) configure set aws_session_token \(.SessionToken)"')
```