TF_IMAGE           :="ci:latest"
TF_LOG             :="ERROR"
PYTHON_IMAGE       :="python:3.9.12-slim-buster"
AZURE_TENANT_ID    :="62fa15fd-0fb1-432a-96fd-ef6e5d53587c"
AZURE_CLIENT_ID    :="9013b511-b735-43bf-ba6e-44e5554a8e0b"
SNOWFLAKE_ACCOUNT  :="ys22818.eu-west-1"
SNOWFLAKE_USER     :="kpodkov"
WORKDIR            := "/prod/snowflake"

docker-build: docker-build
plan: clean init generate-config
apply: plan

docker-build:
	@echo "==================="
	@echo " Building CI Image"
	@echo "==================="
	docker build -t ${TF_IMAGE} ${PWD}/docker/

clean:
	@echo "========================"
	@echo " Cleaning tmp directory"
	@echo "========================"
	@docker run --rm -it \
	  --volume "${HOME}/.aws:/root/.aws" \
	  --volume "${HOME}/.azure:/root/.azure" \
	  --volume "${PWD}:/infra" \
	  --workdir "/infra" \
	  "${PYTHON_IMAGE}" \
	  find . -type d -name "tmp" -prune -exec rm -rf {} \;
	@docker run --rm -it \
	  --volume "${HOME}/.aws:/root/.aws" \
	  --volume "${HOME}/.azure:/root/.azure" \
	  --volume "${PWD}:/infra" \
	  --workdir "/infra" \
	  "${PYTHON_IMAGE}" \
	  find . -type d -name ".terraform" -prune -exec rm -rf {} \;
	@docker run --rm -it \
	  --volume "${HOME}/.aws:/root/.aws" \
	  --volume "${HOME}/.azure:/root/.azure" \
	  --volume "${PWD}:/infra" \
	  --workdir "/infra" \
	  "${PYTHON_IMAGE}" \
	  find . -type f -name "tfplan" -prune -exec rm -rf {} \;

generate-config:
	@echo "============================================="
	@echo " Generating config.json for terraform locals"
	@echo "============================================="
	@docker run -it \
	  --volume "${HOME}/.aws:/root/.aws" \
	  --volume "${HOME}/.azure:/root/.azure" \
	  --volume "${PWD}:/infra" \
	  --workdir "/infra" \
	  ${PYTHON_IMAGE} \
	  pip3 install -r scripts/requirements.txt >/dev/null; python3 scripts/generate_snowflake_config.py

init:
	@echo "================"
	@echo " Terraform Init"
	@echo "================"
	@docker run -it \
 	  --env TF_VAR_azure_tenant_id=${AZURE_TENANT_ID} \
 	  --env TF_VAR_azure_client_id=${AZURE_CLIENT_ID} \
 	  --env TF_VAR_azure_client_secret=${AZURE_SECRET} \
 	  --env TF_VAR_snowflake_account=${SNOWFLAKE_ACCOUNT} \
 	  --env TF_VAR_snowflake_user=${SNOWFLAKE_USER} \
 	  --env TF_VAR_snowflake_password="${SNOWFLAKE_PASSWORD}" \
 	  --env TF_LOG="${TF_LOG}" \
 	  --volume "${HOME}/.aws:/root/.aws" \
 	  --volume "${HOME}/.azure:/root/.azure" \
 	  --volume "${PWD}:/infra" \
 	  --workdir "/infra/${WORKDIR}" \
 	  ${TF_IMAGE} \
 	  init

plan:
	@echo "================"
	@echo " Terraform Plan"
	@echo "================"
	@docker run -it \
 	  --env TF_VAR_azure_tenant_id=${AZURE_TENANT_ID} \
 	  --env TF_VAR_azure_client_id=${AZURE_CLIENT_ID} \
 	  --env TF_VAR_azure_client_secret=${AZURE_SECRET} \
 	  --env TF_VAR_snowflake_account=${SNOWFLAKE_ACCOUNT} \
 	  --env TF_VAR_snowflake_user=${SNOWFLAKE_USER} \
 	  --env TF_VAR_snowflake_password="${SNOWFLAKE_PASSWORD}" \
   	  --env TF_LOG="${TF_LOG}" \
 	  --volume "${HOME}/.aws:/root/.aws" \
 	  --volume "${HOME}/.azure:/root/.azure" \
 	  --volume "${PWD}:/infra" \
 	  --workdir "/infra/${WORKDIR}" \
 	  ${TF_IMAGE} \
 	  plan -out=tfplan -input=false

apply:
	@echo "================="
	@echo " Terraform Apply"
	@echo "================="
	@docker run -it \
 	  --env TF_VAR_azure_tenant_id=${AZURE_TENANT_ID} \
 	  --env TF_VAR_azure_client_id=${AZURE_CLIENT_ID} \
 	  --env TF_VAR_azure_client_secret=${AZURE_SECRET} \
 	  --env TF_VAR_snowflake_account=${SNOWFLAKE_ACCOUNT} \
 	  --env TF_VAR_snowflake_user=${SNOWFLAKE_USER} \
 	  --env TF_VAR_snowflake_password="${SNOWFLAKE_PASSWORD}" \
 	  --env TF_LOG="${TF_LOG}" \
 	  --volume "${HOME}/.aws:/root/.aws" \
 	  --volume "${HOME}/.azure:/root/.azure" \
 	  --volume "${PWD}:/infra" \
 	  --workdir "/infra/${WORKDIR}" \
 	  ${TF_IMAGE} \
 	  apply -input=false tfplan