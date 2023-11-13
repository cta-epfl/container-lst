# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG OWNER=jupyter
ARG BASE_CONTAINER=$OWNER/minimal-notebook:python-3.8.13
FROM $BASE_CONTAINER

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

# Fix: https://github.com/hadolint/hadolint/wiki/DL4006
# Fix: https://github.com/koalaman/shellcheck/wiki/SC3014
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    # for cython: https://cython.readthedocs.io/en/latest/src/quickstart/install.html
    build-essential \
    # for latex labels
    cm-super \
    dvipng \
    # for matplotlib anim
    ffmpeg && \
    apt-get clean && rm -rf /var/lib/apt/lists/*



ARG LSTCHAIN_VER=0.9.6 
RUN wget https://raw.githubusercontent.com/cta-observatory/cta-lstchain/v$LSTCHAIN_VER/environment.yml 
#    conda env update --file environment.yml 
    #conda env create -n lst -f environment.yml 

# && \
#RUN conda init bash && \
#    conda activate lst && \
RUN mamba env update --name base --file environment.yml
RUN pip install lstchain==$LSTCHAIN_VER  \
    'jupyter_server>=2.0.0'  \
    pandas==1.4.1 \
    jupyterhub\>=4.0.0

RUN pip install git+https://github.com/cta-epfl/ctadata.git@v0.4.0-beta1

RUN fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

USER ${NB_UID}

#RUN conda install -c conda-forge gammapy
#RUN conda install -c conda-forge dask-labextension && \
#    jupyter labextension install dask-labextension

#RUN jupyter serverextension enable --py --sys-prefix dask_labextension

# Install facets which does not have a pip or conda package at the moment
# WORKDIR /tmp
# RUN git clone https://github.com/PAIR-code/facets.git && \
#     jupyter nbextension install facets/facets-dist/ --sys-prefix && \
#     rm -rf /tmp/facets && \
#     fix-permissions "${CONDA_DIR}" && \
#     fix-permissions "/home/${NB_USER}"

# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME="/home/${NB_USER}/.cache/"

# RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
#     fix-permissions "/home/${NB_USER}"

#RUN pip install astropy regions matplotlib scipy\<1.10 

#ARG GAMMAPY_REVISION=v1.0
#RUN pip install git+https://github.com/gammapy/gammapy/@$GAMMAPY_REVISION

USER ${NB_UID}

#ADD dask.yaml /etc/dask/dask.yaml

WORKDIR "${HOME}"
