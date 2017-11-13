ARG ARCH=x86_64
FROM rcarmo/ubuntu-python:userland-${ARCH}

MAINTAINER Rui Carmo https://github.com/rcarmo

RUN cd /tmp \
 && wget https://www.python.org/ftp/python/3.6.3/Python-3.6.3.tgz \
 && tar xvf Python-3.6.3.tgz \
 && cd Python-3.6.3 \
 && ./configure --enable-optimizations \
 && make -j8 \
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
