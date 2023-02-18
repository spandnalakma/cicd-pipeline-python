FROM centos:7

RUN yum update -y && \
    yum install -y wget

ENV PATH="/opt/conda/bin:$PATH"

ARG CONDA_VERSION=py310_22.11.1-1
ARG MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh"
ARG SHA256SUM="00938c3534750a0e4069499baf8f4e6dc1c2e471c86a59caa0dd03f4a9269db6"

SHELL ["/bin/bash", "-c"]

RUN wget "${MINICONDA_URL}" -O miniconda.sh -q && \
    echo "${SHA256SUM} miniconda.sh" > shasum && \
    if [ "${CONDA_VERSION}" != "latest" ]; then sha256sum --check --status shasum; fi && \
    mkdir -p /opt && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh shasum && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy

RUN conda update -y conda &&\
    conda list &&\
    mkdir -p /opt/app && \
    chmod -R g+rwX /opt/conda && \
    chmod -R g+rwX /opt/app

COPY . /opt/app

WORKDIR /opt/app

RUN conda env create --name app --file env.yml && \
    source activate app && \
    conda info && \
    conda list

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["source activate app && gunicorn -b 0.0.0.0:5000 main:app"]


