FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC
COPY system.txt .
RUN apt update && \
    apt install -y \
        python3 \
        python3-dev \
        python3-venv \
        python3-pip \
        python3-wheel && \
    xargs apt install -y < system.txt
RUN rm system.txt

ARG USER_NAME=user
ARG USER_ID=1000
ARG GROUP_NAME=$USER_NAME
ARG GROUP_ID=$USER_ID
ARG HOME_DIR=/home/$USER_NAME
ARG SHELL=/bin/bash
RUN groupadd \
        --gid $GROUP_ID \
        $GROUP_NAME && \
    useradd \
        --uid $USER_ID \
        --gid $GROUP_ID \
        --home-dir $HOME_DIR \
        --shell $SHELL \
        --create-home \
        $USER_NAME
USER $USER_NAME
WORKDIR $HOME_DIR

ARG VENV_DIR=$HOME_DIR/.virtualenvs/venv
RUN python3 -m venv $VENV_DIR
ENV PATH=$VENV_DIR/bin:$PATH

RUN pip3 install --upgrade pip
COPY requirements.txt .
RUN pip3 install -r requirements.txt
RUN rm requirements.txt
