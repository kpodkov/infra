FROM hashicorp/terraform:1.1.7

# Customize TF image if desired

# ===================
#  Install Azure CLI
# ===================
# https://github.com/Azure/azure-cli/issues/19591#issue-998886589
#RUN apk add py3-pip
#RUN apk add gcc musl-dev python3-dev libffi-dev openssl-dev cargo make
#RUN pip install --upgrade pip; pip install azure-cli

# ===================
# Install python/pip
# ===================
#ENV PYTHONUNBUFFERED=1
#RUN apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python
#RUN python3 -m ensurepip
#RUN pip3 install --no-cache --upgrade pip setuptools