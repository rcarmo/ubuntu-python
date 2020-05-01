export QEMU_VERSION=4.2.0-4
export BASE_IMAGE=ubuntu:18.04
export BUILD_IMAGE=local/ubuntu-base
export IMAGE_NAME=rcarmo/ubuntu-python
export VCS_REF=`git rev-parse --short HEAD`
export VCS_URL=https://github.com/rcarmo/ubuntu-python
export BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
export TARGET_ARCHITECTURES=amd64 arm32v7 arm64v8
export QEMU_ARCHITECTURES=arm aarch64
export MAJOR_VERSION=3.8
export PYTHON_VERSION=3.8.2
export CORES=`cat /proc/cpuinfo | grep processor | wc -l`
export SHELL=/bin/bash

.PHONY: qemu wrap node push manifest clean

qemu:
	@echo "==> Setting up QEMU"
	docker pull multiarch/qemu-user-static:register
	-docker run --rm --privileged multiarch/qemu-user-static:register --reset
	-mkdir tmp
	$(foreach ARCH, $(QEMU_ARCHITECTURES), make fetch-qemu-$(ARCH);)
	@echo "==> Done setting up QEMU"

fetch-qemu-%:
	$(eval ARCH := $*)
	@echo "--> Fetching QEMU binary for $(ARCH)"
	cd tmp && \
	curl -L -o qemu-$(ARCH)-static.tar.gz \
		https://github.com/multiarch/qemu-user-static/releases/download/v$(QEMU_VERSION)/qemu-$(ARCH)-static.tar.gz && \
	tar xzf qemu-$(ARCH)-static.tar.gz && \
	cp qemu-$(ARCH)-static ../qemu/
	@echo "--> Done."

all: build-userland build build-onbuild push

wrap:
	@echo "==> Building local base containers"
	$(foreach ARCH, $(TARGET_ARCHITECTURES), make wrap-$(ARCH);)
	@echo "==> Done."

wrap-amd64:
	docker pull amd64/$(BASE_IMAGE)
	docker tag amd64/$(BASE_IMAGE) $(BUILD_IMAGE):amd64

wrap-translate-%: 
	@if [[ "$*" == "arm64v8" ]] ; then \
	   echo "aarch64"; \
	else \
		echo "arm"; \
	fi 

wrap-%:
	$(eval ARCH := $*)
	@echo "--> Building local base container for $(ARCH)"
	docker build --build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg ARCH=$(shell make -s wrap-translate-$(ARCH)) \
		--build-arg BASE=$(ARCH)/$(BASE_IMAGE) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg VCS_URL=$(VCS_URL) \
		-t $(BUILD_IMAGE):$(ARCH) qemu
	@echo "--> Done building local base container for $(ARCH)"


build-userland:
	$(foreach arch, $(TARGET_ARCHITECTURES), make build-userland-$(arch);)

build-userland-%:
	$(eval ARCH := $*)
	@echo "--> Building userland container for $(ARCH)"
	docker build --build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg VCS_URL=$(VCS_URL) \
		--build-arg BASE=$(BUILD_IMAGE):$(ARCH) \
		-t $(IMAGE_NAME):userland-$(ARCH) userland
	@echo "--> Done building userland container for $(ARCH)"

build:
	$(foreach arch, $(TARGET_ARCHITECTURES), make build-$(arch);)

build-%:
	$(eval ARCH := $*)
	@echo "--> Building base container for $(ARCH)"
	docker build --build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg VCS_URL=$(VCS_URL) \
		--build-arg ARCH=$(ARCH) \
		--build-arg MAJOR_VERSION=$(MAJOR_VERSION) \
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		--build-arg CORES=$(CORES) \
		-t $(IMAGE_NAME):$(MAJOR_VERSION)-$(ARCH) python
	docker tag $(IMAGE_NAME):$(MAJOR_VERSION)-$(ARCH) $(IMAGE_NAME):$(PYTHON_VERSION)-$(ARCH)
	@echo "--> Done building base container for $(ARCH)"

build-onbuild:
	$(foreach arch, $(TARGET_ARCHITECTURES), make build-$(arch);

build-onbuild-%:
	$(eval ARCH := $*)
	@echo "--> Building onbuild container for $(ARCH)"
	docker build --build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg VCS_URL=$(VCS_URL) \
		--build-arg ARCH=$(ARCH) \
		--build-arg MAJOR_VERSION=$(MAJOR_VERSION) \
		-t $(IMAGE_NAME):$(MAJOR_VERSION)-onbuild-$(ARCH) python/onbuild
	@echo "--> Done building onbuild container for $(ARCH)"


clean:
	-docker rm -v $$(docker ps -a -q -f status=exited)
	-docker rmi $$(docker images -q -f dangling=true)
	-docker rmi $$(docker images --format '{{.Repository}}:{{.Tag}}' | grep '$(IMAGE_NAME)')

expand-%: # expand architecture variants for manifest
	@if [ "$*" == "amd64" ] ; then \
	   echo '--arch $*'; \
	elif [[ "$*" == *"arm"* ]] ; then \
	   echo '--arch arm --variant $*' | cut -c 1-21,27-; \
	fi

manifest:
	@echo "==> Building multi-architecture manifest"
	docker manifest create --amend \
		$(IMAGE_NAME):latest \
		$(foreach arch, $(TARGET_ARCHITECTURES), $(IMAGE_NAME):$(MAJOR_VERSION)-$(arch))
	$(foreach arch, $(TARGET_ARCHITECTURES), \
		docker manifest annotate \
			$(IMAGE_NAME):latest \
			$(IMAGE_NAME):$(MAJOR_VERSION)-$(arch) $(shell make expand-$(arch));)
	docker manifest push $(IMAGE_NAME):latest
	docker manifest create --amend \
		$(IMAGE_NAME):onbuild \
		$(foreach arch, $(TARGET_ARCHITECTURES), $(IMAGE_NAME):$(MAJOR_VERSION)-onbuild-$(arch) )
	$(foreach arch, $(TARGET_ARCHITECTURES), \
		docker manifest annotate \
			$(IMAGE_NAME):onbuild \
			$(IMAGE_NAME):$(MAJOR_VERSION)-onbuild-$(arch) $(shell make expand-$(arch));)
	@echo "--> Pushing manifest"
	docker manifest push $(IMAGE_NAME):onbuild
	@echo "--> Published manifest"

push:
	docker push $(IMAGE_NAME)

test:
	docker run -ti $(IMAGE_NAME):$(PYTHON_VERSION)-$(ARCH)
