
ARG CUDA_VERSION=11.3.1
ARG OS_VERSION=20.04
# pull a prebuilt image
FROM nvidia/cuda:${CUDA_VERSION}-cudnn8-devel-ubuntu${OS_VERSION}

# setup timezone
ENV TZ=US/Pacific
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# --- 关键修改：替换为阿里云镜像源 ---
    RUN sed -i "s@http://.*archive.ubuntu.com@http://mirrors.aliyun.com@g" /etc/apt/sources.list && \
    sed -i "s@http://.*security.ubuntu.com@http://mirrors.aliyun.com@g" /etc/apt/sources.list

# 添加阿里云工具链PPA镜像
RUN echo "deb http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse" >> /etc/apt/sources.list

SHELL ["/bin/bash", "-c"]

# Required to build Ubuntu 20.04 without user prompts with DLFW container
ENV DEBIAN_FRONTEND=noninteractive

# Install requried libraries
# 安装基本工具和依赖 - 合并为单个RUN层减少镜像层数
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        software-properties-common \
        wget \
        curl \
        ca-certificates \
        gnupg \
        apt-transport-https && \
    # 添加工具链PPA密钥
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1E9377A2BA9EF27F && \
    add-apt-repository ppa:ubuntu-toolchain-r/test && \
    # 更新并安装主要依赖
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
        libcurl4-openssl-dev \
        zlib1g-dev \
        git \
        sudo \
        ssh \
        libssl-dev \
        pbzip2 \
        pv \
        bzip2 \
        unzip \
        devscripts \
        lintian \
        fakeroot \
        dh-make \
        build-essential \
        libx11-6 \
        nano \
        graphviz \
        libgl1-mesa-glx \
        openssh-server \
        libgtk2.0-0 \
        libcanberra-gtk-module \
        libsm6 \
        libxext6 \
        libxrender-dev \
        libgtk2.0-dev \
        pkg-config \
        libibverbs-dev && \
    # 清理缓存减小镜像大小
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 设置OpenMPI环境变量
# libopenmpi-dev \
# ENV OMPI_MCA_btl_vader_single_copy_mechanism=none

# Install Miniconda
# 安装 Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda && \
    rm Miniconda3-latest-Linux-x86_64.sh

# 设置环境变量
ENV PATH=/opt/conda/bin:$PATH

# 接受服务条款
RUN conda init bash && \
    conda config --set always_yes yes --set changeps1 no && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# 创建并激活环境
RUN conda create -n bevformer python=3.8
ENV CONDA_DEFAULT_ENV=bevformer
ENV CONDA_PREFIX=/opt/conda/envs/$CONDA_DEFAULT_ENV
ENV PATH=$CONDA_PREFIX/bin:$PATH

# Set environment and working directory
ENV CUDA_HOME=/usr/local/cuda
ENV LD_LIBRARY_PATH=$CUDA_HOME/lib64:$CUDA_HOME/extras/CUPTI/lib64/:$LD_LIBRARY_PATH
ENV PATH=$CUDA_HOME/bin:$PATH
ENV CFLAGS="-I$CUDA_HOME/include $CFLAGS"
ENV FORCE_CUDA="1"
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/miniconda3/envs/bin:$PATH

# install pytorch
RUN pip install torch==1.9.1+cu111 torchvision==0.10.1+cu111 torchaudio==0.9.1 -f https://download.pytorch.org/whl/torch_stable.html

# install opencv
RUN python -m pip install opencv-python==4.5.5.62

# install gcc
RUN conda install -c omgarcia gcc-6

# install torchpack
RUN git clone https://github.com/zhijian-liu/torchpack.git
RUN cd torchpack && python -m pip install -e .

# install other dependencies
RUN python -m pip install mmcv-full==1.4.0 -f https://download.openmmlab.com/mmcv/dist/cu111/torch1.9.0/index.html
RUN python -m pip install pillow==8.4.0 \
                          tqdm \
                          mmdet==2.14.0 \
                          mmsegmentation==0.14.1 \
                          numba \
                          mpi4py \
                          nuscenes-devkit \
                          setuptools==59.5.0 \
                          fvcore

# install mmdetection3d from source
ENV TORCH_CUDA_ARCH_LIST="6.0 6.1 7.0+PTX"
ENV TORCH_NVCC_FLAGS="-Xfatbin -compress-all"
ENV CMAKE_PREFIX_PATH="$(dirname $(which conda))/../"

COPY . /BEVFormer

RUN apt-get update && apt-get install -y ffmpeg libsm6 libxext6 git ninja-build libglib2.0-0 libsm6 libxrender-dev libxext6 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN cd /BEVFormer && git clone https://github.com/open-mmlab/mmdetection3d.git && \
    cd /BEVFormer/mmdetection3d && \
    git checkout v0.17.1 && \
    python -m pip install -r requirements/build.txt && \
    python -m pip install --no-cache-dir -e .

# install timm
RUN python -m pip install timm
RUN pip install timm==0.6.12 torchmetrics==0.3.2 prettytable==3.5.0 einops fvcore seaborn iopath==0.1.9 timm==0.6.13  typing-extensions==4.5.0 pylint ipython==8.12  numpy==1.19.5 matplotlib==3.5.2 numba==0.48.0 pandas==1.4.4 scikit-image==0.19.3 setuptools==59.5.0
RUN pip install detectron2 -f https://dl.fbaipublicfiles.com/detectron2/wheels/cu113/torch1.9/index.html
# detectron2 install
# RUN python -m pip install 'git+https://github.com/facebookresearch/detectron2.git'
# pip install einops fvcore seaborn iopath==0.1.9 timm==0.6.13  typing-extensions==4.5.0 pylint ipython==8.12  numpy==1.19.5 matplotlib==3.5.2 numba==0.48.0 pandas==1.4.4 scikit-image==0.19.3 setuptools==59.5.0
# pip install detectron2 -f https://dl.fbaipublicfiles.com/detectron2/wheels/cu113/torch1.9/index.html
# libraries path
RUN ln -s /usr/local/cuda/lib64/libcusolver.so.11 /usr/local/cuda/lib64/libcusolver.so.10

WORKDIR /BEVFormer
USER root
RUN ["/bin/bash"]