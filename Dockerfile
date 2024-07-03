# Copyright (c) Orange S.A.
# Distributed under the terms of the BSD-3-Clause-Clear License.

# ARGs to set default values
ARG OWNER=jupyter
ARG BASE_CONTAINER=$OWNER/scipy-notebook

# Base image (platform is set to amd64 since Khiops is not built yet for ARM)
FROM --platform=linux/amd64 $BASE_CONTAINER

LABEL maintainer="Khiops Team <khiops.team@orange.com>"

# Fixes for some issues faced during image creation
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Switch to ROOT for installation
USER root
ARG KHIOPS_VERSION=10.2.2
ARG KHIOPS_PYTHON_VERSION=10.2.2.0

# Install Khiops using apt-get
RUN apt-get update && \
    apt-get install -y wget && \
    CODENAME=$(sed -rn 's|^deb\s+\S+\s+(\w+)\s+(\w+\s+)?main.*$|\1|p' /etc/apt/sources.list) && \
    wget "https://github.com/KhiopsML/khiops/releases/download/${KHIOPS_VERSION}/khiops-core-openmpi_${KHIOPS_VERSION}-1-${CODENAME}.amd64.deb" && \
    dpkg -i "khiops-core-openmpi_${KHIOPS_VERSION}-1-${CODENAME}.amd64.deb" || apt-get -f -y install && \
    rm "khiops-core-openmpi_${KHIOPS_VERSION}-1-${CODENAME}.amd64.deb" && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    pip install "https://github.com/KhiopsML/khiops-python/releases/download/10.2.0.0/khiops-10.2.0.0.tar.gz" && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Switch back to the original user
USER $NB_UID
