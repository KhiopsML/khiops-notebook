# Copyright (c) Orange S.A.
# Distributed under the terms of the BSD-3-Clause-Clear License.

# ARGs to set default values
ARG REGISTRY=quay.io
ARG OWNER=jupyter
ARG TAG=x86_64-ubuntu-24.04
ARG BASE_CONTAINER=$REGISTRY/$OWNER/scipy-notebook:$TAG
FROM $BASE_CONTAINER

# Base image (platform is set to amd64 since Khiops is not built yet for ARM)
FROM --platform=linux/amd64 $BASE_CONTAINER

LABEL maintainer="Khiops Team <khiops.team@orange.com>"

# Fixes for some issues faced during image creation
#SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Switch to ROOT for installation
USER root
ARG KHIOPS_CORE_PACKAGE_NAME=khiops-core-openmpi
ARG KHIOPS_VERSION=10.3.2
ARG KHIOPS_PYTHON_VERSION=10.3.2.1
ARG GCS_DRIVER_VERSION=0.0.13
ARG S3_DRIVER_VERSION=0.0.13

# Install Khiops
RUN apt-get update && apt-get install -y ca-certificates lsb-release curl && \
    CODENAME=$(lsb_release -cs) && \
    TEMP_DEB="$(mktemp)" && \
    curl -L "https://github.com/KhiopsML/khiops/releases/download/${KHIOPS_VERSION}/${KHIOPS_CORE_PACKAGE_NAME}_${KHIOPS_VERSION}-1-${CODENAME}.amd64.deb" -o "$TEMP_DEB" && \
    dpkg -i "$TEMP_DEB" || apt-get -f -y install --no-install-recommends && \
    rm -f $TEMP_DEB && \
    curl -L "https://github.com/KhiopsML/khiopsdriver-gcs/releases/download/${GCS_DRIVER_VERSION}/khiops-driver-gcs_${GCS_DRIVER_VERSION}-1-${CODENAME}.amd64.deb" -o "$TEMP_DEB" && \
    dpkg -i --force-all "$TEMP_DEB" && \
    rm -f $TEMP_DEB && \
    curl -L "https://github.com/KhiopsML/khiopsdriver-s3/releases/download/${S3_DRIVER_VERSION}/khiops-driver-s3_${S3_DRIVER_VERSION}-1-${CODENAME}.amd64.deb" -o "$TEMP_DEB" && \
    dpkg -i --force-all "$TEMP_DEB" && \
    rm -f $TEMP_DEB && \
    rm -rf /var/lib/apt/lists/* && \
    pip install "https://github.com/KhiopsML/khiops-python/releases/download/${KHIOPS_PYTHON_VERSION}/khiops-${KHIOPS_PYTHON_VERSION}.tar.gz" && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Switch back to the original user
USER $NB_UID
