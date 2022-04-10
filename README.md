# infra
 

```shell
# Build CI image 
docker build -t ci:latest ./docker/

```



```shell
az login --service-principal --username $TF_VAR_azure_client_id --password $TF_VAR_azure_client_secret --tenant $TF_VAR_azure_tenant_id
az login --service-principal --username $AZURE_CLIENT_ID --password $AZURE_SECRET --tenant $AZURE_TENANT_ID
```
