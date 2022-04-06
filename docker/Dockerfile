FROM hashicorp/terraform:1.1.7

# ===================
#  Install Azure CLI
# ===================
# https://github.com/Azure/azure-cli/issues/19591#issue-998886589
RUN apk add py3-pip
RUN apk add gcc musl-dev python3-dev libffi-dev openssl-dev cargo make
RUN pip install --upgrade pip; pip install azure-cli



#ENTRYPOINT ["/bin/ash"]