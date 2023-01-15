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

# Enabling SAML2 on Snowflake
- See https://docs.microsoft.com/en-us/azure/active-directory/saas-apps/snowflake-tutorial

```shell
DROP SECURITY INTEGRATION IF EXISTS AZURE_SAML;
CREATE OR REPLACE SECURITY INTEGRATION AZURE_SAML
    TYPE = SAML2
    ENABLED = TRUE
    SAML2_ENABLE_SP_INITIATED = TRUE
    SAML2_SP_INITIATED_LOGIN_PAGE_LABEL = "Azure"
    SAML2_ISSUER = 'https://sts.windows.net/{tenant_id}/'
    SAML2_SSO_URL = 'https://login.microsoftonline.com/{tenant_id}/saml2'
    SAML2_PROVIDER = 'Custom'
    SAML2_X509_CERT = '';
```