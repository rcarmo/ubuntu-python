ARG ARCH=x86_64
ARG MAJOR_VERSION=3.6
FROM rcarmo/ubuntu-python:${MAJOR_VERSION}-${ARCH} as runtime

MAINTAINER Rui Carmo https://github.com/rcarmo

ARG VCS_REF
ARG VCS_URL
ARG BUILD_DATE
LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.build-date=$BUILD_DATE 

# install requirements
# this way when you build you won't need to install again
# ans since COPY is cached we don't need to wait
ONBUILD COPY ./requirements.txt /tmp/requirements.txt
ONBUILD RUN pip install -r /tmp/requirements.txt

