# Copyright (c) Orange S.A.
# Distributed under the terms of the BSD-3-Clause-Clear License.

# ARGs to set default values
ARG REGISTRY=quay.io
ARG OWNER=jupyter
ARG TAG=ubuntu-24.04
ARG BASE_CONTAINER=$REGISTRY/$OWNER/scipy-notebook:$TAG
FROM $BASE_CONTAINER

LABEL maintainer="Khiops Team <khiops.team@orange.com>"

# Switch to ROOT for installation
USER root

# Version of the Khiops Python library Pip package on the PyPI or Test PyPI repositories
# this version can be either official, following this pattern : [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+
# or pre-release (alpha, beta, release candidate), following this other pattern : [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(rc|a|b)[0-9]+
ARG KHIOPS_PYTHON_VERSION=11.0.1.0

# Install Khiops, Khiops Library and all the remote drivers
RUN apt-get update && apt-get install -y ca-certificates curl &&  \
    if [[ "$KHIOPS_PYTHON_VERSION" =~ ^[0-9\.]+$ ]]; then \
      # The library has an official version \
      NEED_EXTRA_INDEX_URL=""; \
    else \
      # The library has a pre-release version \
      NEED_EXTRA_INDEX_URL="--extra-index-url https://test.pypi.org/simple"; \
    fi && \
    pip install ${NEED_EXTRA_INDEX_URL} khiops[s3,gcs,azure]==${KHIOPS_PYTHON_VERSION} && \
    # Make the following directories (human) user-writable so that : \
    # - the user can install extra Python packages in the system-wide Python environment based on Conda (inherited from the upstream Docker image) \
    # - the user can save his personal files and notebooks in his home \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Switch back to the original user
USER $NB_UID