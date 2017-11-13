FROM ubuntu:16.04

MAINTAINER Rui Carmo https://github.com/rcarmo

RUN apt update \
 && apt dist-upgrade -y \
 && apt install -y \
     build-essential \
     libbz2-dev \
     libexpat1-dev \
     libffi-dev \
     libgdbm-dev \
     libjpeg-dev \
     liblapack-dev \
     libncurses5-dev \
     libreadline-dev \
     libssl-dev \
     libsqlite3-dev \
     libxml2-dev \
     libxslt-dev \
     git \
     gfortran \
     wget \
     zlib1g-dev \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN cd /tmp \
 && wget https://www.python.org/ftp/python/3.6.3/Python-3.6.3.tgz \
 && tar xvf Python-3.6.3.tgz \
 && cd Python-3.6.3 \
 && ./configure --enable-optimizations \
 && make -j4 \
 && make altinstall \
 && rm -rf /tmp/Python*

# create some useful symlinks that are expected to exist
RUN cd /usr/bin \
 && ln -sf easy_install-3.6 easy_install \
 && ln -sf idle3.6 idle \
 && ln -sf pydoc3.6 pydoc \
 && ln -sf python3.6 python \
 && ln -sf python-config3.6 python-config \
 && ln -sf pip3.6 pip \
 && pip install --upgrade pip

# since we will be "always" mounting the volume, we can set this up
CMD python
