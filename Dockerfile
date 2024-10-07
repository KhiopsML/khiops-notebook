# Copyright (c) Orange S.A.
# Distributed under the terms of the BSD-3-Clause-Clear License.

# ARGs to set default values
ARG REGISTRY=quay.io
ARG OWNER=jupyter
ARG BASE_CONTAINER=$REGISTRY/$OWNER/scipy-notebook
FROM $BASE_CONTAINER

# Base image (platform is set to amd64 since Khiops is not built yet for ARM)
FROM --platform=linux/amd64 $BASE_CONTAINER

LABEL maintainer="Khiops Team <khiops.team@orange.com>"

# Fixes for some issues faced during image creation
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Switch to ROOT for installation
USER root
ARG KHIOPS_CORE_PACKAGE_NAME=khiops-core-openmpi
ARG KHIOPS_VERSION=10.2.2
ARG KHIOPS_PYTHON_VERSION=10.2.2.4
ARG GCS_DRIVER_VERSION=0.0.1
ARG GCS_DRIVER_RC_EXT=-rc1
ARG S3_DRIVER_VERSION=0.0.1
ARG S3_DRIVER_RC_EXT=-rc1

# Install Khiops
RUN apt-get update && \
    apt-get install --no-install-recommends ca-certificates curl && \
    export CODENAME=$(sed -rn 's|^deb\s+\S+\s+(\w+)\s+(\w+\s+)?main.*$|\1|p' /etc/apt/sources.list) && \
    TEMP_DEB="$(mktemp)" && \
    curl -L "https://github.com/KhiopsML/khiops/releases/download/${KHIOPS_VERSION}/${KHIOPS_CORE_PACKAGE_NAME}_${KHIOPS_VERSION}-1-${CODENAME}.amd64.deb" -o "$TEMP_DEB" && \
    dpkg -i "$TEMP_DEB" || apt-get -f -y install --no-install-recommends && \
    rm -f $TEMP_DEB && \
    curl -L "https://github.com/KhiopsML/khiopsdriver-gcs/releases/download/${GCS_DRIVER_VERSION}${GCS_DRIVER_RC_EXT}/khiops-driver-gcs_0.1.0-1-${CODENAME}.amd64.deb" -o "$TEMP_DEB" && \
    dpkg -i --force-all "$TEMP_DEB" && \
    rm -f $TEMP_DEB && \
    curl -L "https://github.com/KhiopsML/khiopsdriver-s3/releases/download/${S3_DRIVER_VERSION}${S3_DRIVER_RC_EXT}/khiops-driver-s3_0.1.0-1-${CODENAME}.amd64.deb" -o "$TEMP_DEB" && \
    dpkg -i --force-all "$TEMP_DEB" && \
    rm -f $TEMP_DEB && \
    rm -rf /var/lib/apt/lists/* && \
    pip install "https://github.com/KhiopsML/khiops-python/releases/download/10.2.2.0/khiops-10.2.2.0.tar.gz" && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Switch back to the original user
USER $NB_UID
