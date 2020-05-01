export ARCH?=$(shell arch)
ifneq (,$(findstring armv6,$(ARCH)))
export BASE=arm32v6/ubuntu:18.04
export ARCH=arm32v6
else ifneq (,$(findstring armv7,$(ARCH)))
export BASE=arm32v7/ubuntu:18.04
export ARCH=arm32v7
else
export BASE=ubuntu:18.04
export ARCH=amd64
endif
export IMAGE_NAME=rcarmo/ubuntu-python
export VCS_REF=`git rev-parse --short HEAD`
export VCS_URL=https://github.com/rcarmo/ubuntu-python
export BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
export MAJOR_VERSION=3.8
export PYTHON_VERSION=3.8.2
export CORES=`cat /proc/cpuinfo | grep processor | wc -l`

all: build-userland build build-onbuild push

build-userland:
	docker build --build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg VCS_URL=$(VCS_URL) \
		--build-arg BASE=$(BASE) \
		-t $(IMAGE_NAME):userland-$(ARCH) userland

build:
	docker build --build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg VCS_URL=$(VCS_URL) \
		--build-arg ARCH=$(ARCH) \
		--build-arg MAJOR_VERSION=$(MAJOR_VERSION) \
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		--build-arg CORES=$(CORES) \
		-t $(IMAGE_NAME):$(MAJOR_VERSION)-$(ARCH) python
	docker tag $(IMAGE_NAME):$(MAJOR_VERSION)-$(ARCH) $(IMAGE_NAME):$(PYTHON_VERSION)-$(ARCH)

build-onbuild:
	docker build --build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg VCS_URL=$(VCS_URL) \
		--build-arg ARCH=$(ARCH) \
		--build-arg MAJOR_VERSION=$(MAJOR_VERSION) \
		-t $(IMAGE_NAME):$(MAJOR_VERSION)-onbuild-$(ARCH) python/onbuild

clean:
	-docker rm -v $$(docker ps -a -q -f status=exited)
	-docker rmi $$(docker images -q -f dangling=true)
	-docker rmi $$(docker images --format '{{.Repository}}:{{.Tag}}' | grep '$(IMAGE_NAME)')

manifest:
	docker manifest create  $(IMAGE_NAME):$(MAJOR_VERSION)-onbuild-amd64 \
				$(IMAGE_NAME):$(MAJOR_VERSION)-onbuild-arm32v7

push:
	docker push $(IMAGE_NAME)

test:
	docker run -ti $(IMAGE_NAME):$(PYTHON_VERSION)-$(ARCH)
