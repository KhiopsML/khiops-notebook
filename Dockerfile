# Copyright (c) Orange S.A.
# Distributed under the terms of the BSD-3-Clause-Clear License.

# ARGs to set default values
ARG REGISTRY=quay.io
ARG OWNER=jupyter
ARG TAG=ubuntu-24.04
ARG BASE_CONTAINER=$REGISTRY/$OWNER/scipy-notebook:$TAG
FROM $BASE_CONTAINER

# Base image (platform is set to amd64 since Khiops is not built yet for ARM)
FROM $BASE_CONTAINER

LABEL maintainer="Khiops Team <khiops.team@orange.com>"

# Fixes for some issues faced during image creation
#SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Switch to ROOT for installation
USER root
ARG KHIOPS_PYTHON_VERSION=11.0.1.0-rc.2

# Install Khiops, Khiops Library and all the remote drivers
RUN apt-get update && apt-get install -y ca-certificates curl && \
    artifact_rc_version_transformation="${KHIOPS_PYTHON_VERSION/-rc./rc}" && \
    pip install --extra-index-url https://test.pypi.org/simple khiops[s3,gcs,azure]==${artifact_rc_version_transformation} && \
    fix-permissions "/home/${NB_USER}"

# Switch back to the original user
USER $NB_UID