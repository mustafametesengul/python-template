ARG USE_ROOT=false
ARG USE_CUDA=false

FROM ubuntu:22.04 AS cuda-false

FROM nvidia/cuda:11.7.1-cudnn8-runtime-ubuntu22.04 AS cuda-true

FROM cuda-$USE_CUDA AS base

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

COPY system.txt .

RUN apt update \
    && apt install -y \
        python3 \
        python3-dev \
        python3-venv \
        python3-pip \
        python3-wheel \
    && xargs apt install -y < system.txt \
    && rm -rf /var/lib/apt/lists/* \
    && rm system.txt

FROM base AS root-false

ARG USER_ID=1000
ARG GROUP_ID=$USER_ID
ARG USER_NAME=user
ARG GROUP_NAME=$USER_NAME
ARG HOME_DIR=/home/$USER_NAME
ARG SHELL=/bin/bash

ENV USER_NAME=$USER_NAME
ENV HOME_DIR=$HOME_DIR

RUN groupadd \
        --gid $GROUP_ID \
        $GROUP_NAME \
    && useradd \
        --uid $USER_ID \
        --gid $GROUP_ID \
        --home-dir $HOME_DIR \
        --shell $SHELL \
        --create-home \
        $USER_NAME

FROM base AS root-true

ENV USER_NAME=root
ENV HOME_DIR=/root

FROM root-$USE_ROOT AS final

ARG VENV_DIR=$HOME_DIR/.virtualenvs/venv

ENV PYTHON_DIR=$VENV_DIR/lib/python3.10
ENV SITE_DIR=$PYTHON_DIR/site-packages
ENV PATH=$VENV_DIR/bin:$PATH

USER $USER_NAME
WORKDIR $HOME_DIR

COPY requirements.txt .

RUN python3 -m venv $VENV_DIR \
    && pip3 install --upgrade pip \
    && pip3 install -r requirements.txt \
    && rm requirements.txt

COPY external.pth $SITE_DIR/external.pth
