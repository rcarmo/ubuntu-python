ARG ARCH=x86_64
FROM rcarmo/ubuntu-python:3.6-${ARCH}

MAINTAINER Rui Carmo https://github.com/rcarmo

# install requirements
# this way when you build you won't need to install again
# ans since COPY is cached we don't need to wait
ONBUILD COPY ./requirements.txt /tmp/requirements.txt
ONBUILD RUN pip install -r /tmp/requirements.txt

