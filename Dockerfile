FROM ubuntu:20.04

ARG USER_NAME
ARG USER_ID
ARG GROUP_ID
ARG HOME_DIRECTORY
ARG PYTHON_VERSION

ENV DEBIAN_FRONTEND="noninteractive" TZ="Etc/UTC"
COPY system.txt .
RUN apt update && \
    apt install -y \
        software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt install -y \
        python$PYTHON_VERSION \
        python$PYTHON_VERSION-dev \
        python$PYTHON_VERSION-venv \
        python3-pip \
        python3-wheel && \
    xargs apt install -y < system.txt
RUN rm system.txt

RUN addgroup --gid $GROUP_ID $USER_NAME; exit 0
RUN adduser \
    --home $HOME_DIRECTORY \
    --disabled-password \
    --gecos "" \
    --uid $USER_ID \
    --gid $GROUP_ID \
    $USER_NAME; exit 0
USER $USER_NAME
WORKDIR $HOME_DIRECTORY

ENV VIRTUAL_ENVIRONMENT=$HOME_DIRECTORY/.virtualenvs/main
RUN python$PYTHON_VERSION -m venv $VIRTUAL_ENVIRONMENT
ENV PATH=$VIRTUAL_ENVIRONMENT/bin:$PATH

RUN pip3 install --upgrade pip
COPY requirements.txt .
RUN pip3 install -r requirements.txt
RUN rm requirements.txt

ENV EXTERNAL=$VIRTUAL_ENVIRONMENT/lib/python$PYTHON_VERSION
COPY external.pth $EXTERNAL/site-packages/external.pth
