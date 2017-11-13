export IMAGE_NAME=rcarmo/ubuntu-python
export ARCH?=$(shell arch)

build-userland:
	docker build -t $(IMAGE_NAME):userland-$(ARCH) userland

build-3.6:
	docker build --build-arg ARCH=$(ARCH) -t $(IMAGE_NAME):3.6 3.6
	docker build --build-arg ARCH=$(ARCH) -t $(IMAGE_NAME):3.6-onbuild 3.6/onbuild
	docker tag $(IMAGE_NAME):3.6 $(IMAGE_NAME):3.6.3
	docker tag $(IMAGE_NAME):3.6 $(IMAGE_NAME):latest

push:
	docker push g$(IMAGE_NAME)
