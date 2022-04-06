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
    SAML2_X509_CERT = 'MIIC8DCCAdigAwIBAgIQWNFBKXRoBKdMA6wz0YHz/DANBgkqhkiG9w0BAQsFADA0MTIwMAYDVQQDEylNaWNyb3NvZnQgQXp1cmUgRmVkZXJhdGVkIFNTTyBDZXJ0aWZpY2F0ZTAeFw0yMjA0MDYxOTM5NDZaFw0yNTA0MDYxOTM5NDZaMDQxMjAwBgNVBAMTKU1pY3Jvc29mdCBBenVyZSBGZWRlcmF0ZWQgU1NPIENlcnRpZmljYXRlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnpx8WhTdJib4CZlLL0Qk4Yfxo2uI6HV0fqwZlf+y0ct9IzVEWEt+lvLL4h8ej8UTna87tvLl+KN1vWNbfVqkrRj9VgyMZEYqlmQPyb/d3wYi7BM+J73sMgln+Yx/47qEdK1CNEyTUAab8tocz3iIGr2cIZut7H/vx+NiV4m1klrYSwWcvHgywH7dTAsVTQ7ALpCCLa7v4mjzT9ltCWlgzooLg9uYuDVwoHoZfRZjaWfJL+KPKERtx1+twH0dHrv6689dqmHvwGguKJYDxldfHzyUEfgtH8cRiDqlf0u7ZlAUXRFutWRzv4mgDzdMPzPx9zW4exI7HXMbn/sK/Dhg0QIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQBAs5gfY9LAwGFgEhRD6nFjwvljHRTPYqs1thLvBqISa+XoSxWHV3c8hCg4s7gnacDAuZHZLSLhhO9CpZyUWc7B+YzKd9eZH+GPqayyy8hdW+XUfamR5cC3zrARqBvzZMW7i13S+OdWkhwWaVM/0u6SlRZpGmE2p4AM4fgzshKowLn84GsfgfjbL26TfqcjtznNz6SSM7IPcxK/9Nq34m9BWFtU0Q6M2foO8D9o/fy1elLJywQLpq2jd9v3LsjETlsEdyKWxHF077IwwDsnEWln9b4B6/vXKUM7YrViO1hG2nNncp5G4eAa9QigmVLtiPiVUXaKOjGXD68ZGwP6vp+I';
```