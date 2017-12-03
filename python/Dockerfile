ARG ARCH=x86_64
FROM rcarmo/ubuntu-python:userland-${ARCH} as build-step

MAINTAINER Rui Carmo https://github.com/rcarmo

ARG PYTHON_VERSION=3.6.3
ARG CORES=4
ENV LANG C.UTF-8
RUN cd /tmp \
 && TARGET_ARCH="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
 && wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz \
 && tar xvf Python-${PYTHON_VERSION}.tgz \
 && cd Python-${PYTHON_VERSION} \
 && ./configure \
    --build="$TARGET_ARCH" \
    --with-lto \
    --with-system-ffi \
    --with-system-expat \
    --enable-ipv6 \
    --enable-optimizations \
    --enable-shared \
    --enable-loadable-sqlite-extensions \
 && make -j${CORES} \
 && make altinstall \
 && rm -rf /tmp/Python*

FROM build-step as cleanup-step

# dynamic library bindings and test removal
RUN ldconfig -v \
 && cd /usr/local/bin \
 && find /usr/local -depth \
    \( \( -type d -and \( -name test -or -name tests -or -name __pycache__ \) \) -or \
       \( -type f -and \( -name '*.pyc' -or -name '*.pyo' \) \) \) \
    -exec rm -rf '{}' + \
 && find /var/lib/apt/lists \
         /usr/share/man \
         /usr/share/doc \
         /var/log \
    -type f -exec rm -rf '{}' +

ARG MAJOR_VERSION=3.6
# symlink creation
RUN cd /usr/local/bin \
 && ln -sf easy_install-${MAJOR_VERSION} easy_install \
 && ln -sf idle${MAJOR_VERSION} idle \
 && ln -sf pydoc${MAJOR_VERSION} pydoc \
 && ln -sf python${MAJOR_VERSION} python \
 && ln -sf python-config${MAJOR_VERSION} python-config \
 && ln -sf pip${MAJOR_VERSION} pip \
 && pip${MAJOR_VERSION} --no-cache-dir install --upgrade pip

ARG VCS_REF
ARG VCS_URL
ARG BUILD_DATE
LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.build-date=$BUILD_DATE 

# since we will be "always" mounting the volume, we can set this up
CMD python
