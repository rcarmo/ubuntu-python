ARG ARCH=x86_64
ARG VERSION=${MAJOR_VERSION}.3
ARG MAJOR_VERSION=${MAJOR_VERSION}
FROM rcarmo/ubuntu-python:userland-${ARCH}

MAINTAINER Rui Carmo https://github.com/rcarmo

RUN cd /tmp \
 && wget https://www.python.org/ftp/python/${VERSION}/Python-${VERSION}.tgz \
 && tar xvf Python-${VERSION}.tgz \
 && cd Python-${VERSION} \
 && ./configure \
    --with-lto \
    --enable-optimizations \
 && make -j8 \
 && make altinstall \
 && rm -rf /tmp/Python*

# create some useful symlinks that are expected to exist
RUN cd /usr/local/bin \
 && ln -sf easy_install-${MAJOR_VERSION} easy_install \
 && ln -sf idle${MAJOR_VERSION} idle \
 && ln -sf pydoc${MAJOR_VERSION} pydoc \
 && ln -sf python${MAJOR_VERSION} python \
 && ln -sf python-config${MAJOR_VERSION} python-config \
 && ln -sf pip${MAJOR_VERSION} pip \
 && pip${MAJOR_VERSION} install --upgrade pip

ARG VCS_REF
ARG VCS_URL
ARG BUILD_DATE
LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.build-date=$BUILD_DATE 

# since we will be "always" mounting the volume, we can set this up
CMD python
