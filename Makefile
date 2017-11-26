export ARCH?=$(shell arch)
ifneq (,$(findstring arm,$(ARCH)))
export BASE=armv7/armhf-ubuntu:16.04
export ARCH=armhf
else
export BASE=ubuntu:16.04
endif
export IMAGE_NAME=rcarmo/ubuntu-python
export VCS_REF=`git rev-parse --short HEAD`
export VCS_URL=https://github.com/rcarmo/ubuntu-python
export BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`

all: build-userland build-3.6 build-3.6-onbuild push

build-userland:
	docker build --build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg VCS_URL=$(VCS_URL) \
		--build-arg ARCH=$(ARCH) \
		-t $(IMAGE_NAME):userland-$(ARCH) userland

build-3.6:
	docker build --build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg VCS_URL=$(VCS_URL) \
		--build-arg ARCH=$(ARCH) \
		-t $(IMAGE_NAME):3.6-$(ARCH) 3.6
	docker tag $(IMAGE_NAME):3.6-$(ARCH) $(IMAGE_NAME):3.6.3-$(ARCH)

build-3.6-onbuild:
	docker build --build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg VCS_URL=$(VCS_URL) \
		--build-arg ARCH=$(ARCH) \
		-t $(IMAGE_NAME):3.6-onbuild-$(ARCH) 3.6/onbuild

clean:
	-docker rm -v $$(docker ps -a -q -f status=exited)
	-docker rmi $$(docker images -q -f dangling=true)
	-docker rmi $$(docker images --format '{{.Repository}}:{{.Tag}}' | grep '$(IMAGE_NAME)')

push:
	docker push $(IMAGE_NAME)
