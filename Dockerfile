# Use the base image specifically for the amd64 architecture until the Khiops package becomes available for arm64.
FROM --platform=linux/amd64 jupyter/base-notebook

# Name of the environment and Python version
ARG env_name=Khiops
ARG py_ver=3.10

# Create the environment using mamba
RUN mamba create --yes -p "${CONDA_DIR}/envs/${env_name}" \
    python=${py_ver} \
    ipykernel \
    jupyterlab && \
    mamba clean --all -f -y

# Create Python kernel and link it to Jupyter
RUN "${CONDA_DIR}/envs/${env_name}/bin/python" -m ipykernel install --user --name="${env_name}" && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Install Khiops package using mamba
RUN mamba install --quiet --yes --name ${env_name} -c khiops khiops && \
    mamba clean --all -f -y

# To activate this environment by default in the Jupyter Notebook
USER root
RUN activate_custom_env_script=/usr/local/bin/before-notebook.d/activate_custom_env.sh && \
    echo "#!/bin/bash" > ${activate_custom_env_script} && \
    echo "eval \"$(conda shell.bash activate "${env_name}")\"" >> ${activate_custom_env_script} && \
    chmod +x ${activate_custom_env_script}

# Switch back to notebook user
USER ${NB_UID}

# To set this environment as the default in the terminal
RUN echo "conda activate ${env_name}" >> "${HOME}/.bashrc"
