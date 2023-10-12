# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

# ARGs to set default values
ARG OWNER=jupyter
ARG BASE_CONTAINER=$OWNER/scipy-notebook

# Base image (platform is set to amd64 since Khiops is not built yet for ARM)
FROM --platform=linux/amd64 $BASE_CONTAINER

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

# Fixes for some issues faced during image creation
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Switch to ROOT for installation
USER root
ARG KHIOPS_VERSION=10.1.1
ARG KHIOPS_PYTHON_VERSION=10.2.0a4

# Install Khiops using apt-get
RUN apt-get update && \
    apt-get install -y wget && \
    CODENAME=$(sed -rn 's|^deb\s+\S+\s+(\w+)\s+(\w+\s+)?main.*$|\1|p' /etc/apt/sources.list) && \
    wget "https://github.com/KhiopsML/khiops/releases/download/v${KHIOPS_VERSION}/khiops-core_${KHIOPS_VERSION}-0+${CODENAME}_amd64.deb" && \
    dpkg -i "khiops-core_${KHIOPS_VERSION}-0+${CODENAME}_amd64.deb" || apt-get -f -y install && \
    rm "khiops-core_${KHIOPS_VERSION}-0+${CODENAME}_amd64.deb" && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Switch back to the original user
USER $NB_UID

# Install Khiops-python using pip
RUN pip install --no-cache-dir 'khiops @ git+https://github.com/khiopsml/khiops-python@v${KHIOPS_PYTHON_VERSION}' && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"
