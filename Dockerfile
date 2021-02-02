FROM tensorflow/tensorflow:nightly-gpu

RUN rm -f /etc/apt/sources.list.d/cuda.list && \
    apt-get update && apt-get install -y --allow-downgrades --allow-change-held-packages --no-install-recommends \
        build-essential \
        cmake \
        g++-7 \
        git \
        curl \
        vim \
        wget \
        apt-utils \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    /usr/bin/python3 -m pip install --upgrade --no-cache --no-cache-dir pip

# Install Open MPI
WORKDIR /tmp/openmpi_source

# Download and install open-mpi.
RUN wget https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.4.tar.gz && \
    tar xvf openmpi-4.0.4.tar.gz && \
    cd openmpi-4.0.4 && \
    ./configure --enable-orterun-prefix-by-default && \
    make -j $(nproc) all && \
    make install

# Install Horovod, temporarily using CUDA stubs
# Set the path for OpenMPI binaries, libs and headers to be discoverable
ENV LD_LIBRARY_PATH=/usr/local/lib/openmpi
RUN ldconfig

# Install NCCL
WORKDIR /tmp/nccl
RUN wget https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/nvidia-machine-learning-repo-ubuntu1804_1.0.0-1_amd64.deb && \
    dpkg -i nvidia-machine-learning-repo-ubuntu1804_1.0.0-1_amd64.deb && \
    apt-get update && apt-get install -y --allow-downgrades --allow-change-held-packages --no-install-recommends \
        libnccl2 libnccl-dev && \
    rm -rf /var/lib/apt/lists/*

# Install Horovod
WORKDIR /tmp/horovod

ENV HOROVOD_GPU_OPERATIONS=NCCL
ENV HOROVOD_WITH_TENSORFLOW=1
ENV HOROVOD_WITHOUT_PYTORCH=1
ENV HOROVOD_WITHOUT_MXNET=1

# =========== Uncomment the one you want to build ============== #
# Latest release on PyPI
ENV HOROVOD_FLAVOR="STABLE"

# Latest commit on Github
# ENV HOROVOD_FLAVOR="LATEST"
# =========== Uncomment the one you want to build ============== #

# For long running tasks that would slow down deployments
RUN ldconfig /usr/local/cuda/targets/x86_64-linux/lib/stubs && \
    if [[ "${HOROVOD_FLAVOR}" == "STABLE" ]] ; then \
        echo "BUILDING HOROVOD: STABLE" ; \
        pip3.6 install --no-cache --no-cache-dir horovod ; \
    else \
        echo "BUILDING HOROVOD: LATEST" ; \
        pip3.6 install --no-cache --no-cache-dir git+https://github.com/horovod/horovod.git ; \
    fi && \
    ldconfig

# Install SSH otherwise MPI won't run
RUN rm -f rm /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get update && apt-get install -y --no-install-recommends openssh-client openssh-server && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
