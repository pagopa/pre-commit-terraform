FROM ubuntu:18.04

ARG PRE_COMMIT_VERSION="2.13.0"
ARG TERRAFORM_VERSION="0.15.3"
ARG TFSEC_VERSION="v0.40.2"
ARG TERRAFORM_DOCS_VERSION="v0.14.1"
ARG TFLINT_VERSION="v0.29.1"
ARG TFLINT_RULESET_AZURERM="v0.10.1"
ARG TFLINT_RULESET_AWS="v0.4.3"
ARG TFLINT_RULESET_GOOGLE="v0.9.1"
ARG CHECKOV_VERSION="2.0.192"

# Install general dependencies
RUN apt update && \
    apt install -y curl git gawk unzip software-properties-common

# Install tools
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt install -y python3.7 python3-pip && \
    pip3 install pre-commit==${PRE_COMMIT_VERSION} && \
    curl -L "$(curl -s https://api.github.com/repos/terraform-docs/terraform-docs/releases | grep -o -E "https://.+?${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz")" > terraform-docs.tgz && tar xzf terraform-docs.tgz && chmod +x terraform-docs && mv terraform-docs /usr/bin/ && \
    curl -L "$(curl -s https://api.github.com/repos/terraform-linters/tflint/releases | grep -o -E "https://.+?/${TFLINT_VERSION}/tflint_linux_amd64.zip")" > tflint.zip && unzip tflint.zip && rm tflint.zip && mv tflint /usr/bin/ && \
    curl -L "https://github.com/tfsec/tfsec/releases/download/${TFSEC_VERSION}/tfsec-linux-amd64" > tfsec && chmod +x tfsec && mv tfsec /usr/bin/ && \
    python3.7 -m pip install -U checkov==${CHECKOV_VERSION}

# Install terraform because pre-commit needs it
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
    apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
    apt-get update && apt-get install terraform=${TERRAFORM_VERSION}

# Install tflint ruleset azurerm, aws, google
RUN mkdir -p /root/.tflint.d/plugins && \
    curl -L "https://github.com/terraform-linters/tflint-ruleset-azurerm/releases/download/${TFLINT_RULESET_AZURERM}/tflint-ruleset-azurerm_linux_amd64.zip" > tflint-ruleset-azurerm.zip && unzip tflint-ruleset-azurerm.zip && rm tflint-ruleset-azurerm.zip && mv tflint-ruleset-azurerm /root/.tflint.d/plugins && \
    curl -L "https://github.com/terraform-linters/tflint-ruleset-aws/releases/download/${TFLINT_RULESET_AWS}/tflint-ruleset-aws_linux_amd64.zip" > tflint-ruleset-aws.zip && unzip tflint-ruleset-aws.zip && rm tflint-ruleset-aws.zip && mv tflint-ruleset-aws /root/.tflint.d/plugins && \
    curl -L "https://github.com/terraform-linters/tflint-ruleset-google/releases/download/${TFLINT_RULESET_GOOGLE}/tflint-ruleset-google_linux_amd64.zip" > tflint-ruleset-google.zip && unzip tflint-ruleset-google.zip && rm tflint-ruleset-google.zip && mv tflint-ruleset-google /root/.tflint.d/plugins

# Checking all binaries are in the PATH
RUN terraform --help
RUN pre-commit --help
RUN terraform-docs --help
RUN tflint --help
RUN tfsec --help
RUN checkov --help

ENTRYPOINT [ "pre-commit" ]
