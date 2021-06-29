FROM ubuntu:18.04

RUN apt-get update \
  && apt-get install --no-install-recommends -y \
  sudo \
  wget \
  vim \
  build-essential \
  python \
  python-pip \
  git \
  gcc-aarch64-linux-gnu \
  gcc-arm-linux-gnueabihf \
  libgcc-5-dev \
  uuid-dev \
  nasm \
  iasl \
  zip \
  && apt-get clean


ARG USER_NAME=dummyuser
ARG USER_PASS=dummyuser
ARG USER_HOME=/home/$USER_NAME

RUN useradd -m $USER_NAME \
  && echo $USER_NAME:$USER_PASS | chpasswd \
  && adduser $USER_NAME sudo

ARG SOME_EDK_PKG_DIR=$USER_HOME/SomeEdkPkg
RUN mkdir $SOME_EDK_PKG_DIR && chown $USER_NAME:$USER_NAME $SOME_EDK_PKG_DIR
VOLUME $SOME_EDK_PKG_DIR

ARG EDK_REMOTE="https://github.com/tianocore/edk2.git"
ARG EDK_BRANCH="master"
ARG EDK_PATH=$USER_HOME/edk2

RUN git clone --filter=blob:none --single-branch --branch $EDK_BRANCH $EDK_REMOTE $EDK_PATH && \
  cd $EDK_PATH && \
  git submodule update --init && \
  make -C BaseTools && \
  cd - && \
  chown -R $USER_NAME:$USER_NAME $EDK_PATH

USER $USER_NAME

ENV EDK_DIR=$EDK_PATH
ENV GCC5_AARCH64_PREFIX="aarch64-linux-gnu-" 
ENV GCC5_ARM_PREFIX="arm-linux-gnueabihf-" 

WORKDIR $SOME_EDK_PKG_DIR
