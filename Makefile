export IMAGE_NAME=rcarmo/ubuntu-python
export ARCH?=$(shell arch)
export VCS_REF=`git rev-parse --short HEAD`
export BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`

build-userland:
	docker build -t $(IMAGE_NAME):userland-$(ARCH) userland

build-3.6:
	docker build --build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg ARCH=$(ARCH) \
		-t $(IMAGE_NAME):3.6-$(ARCH) 3.6
	docker build --build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg ARCH=$(ARCH) \
		-t $(IMAGE_NAME):3.6-onbuild-$(ARCH) 3.6/onbuild
	docker tag $(IMAGE_NAME):3.6-$(ARCH) $(IMAGE_NAME):3.6.3-$(ARCH)

clean:
	-docker rm -v $$(docker ps -a -q -f status=exited)
	-docker rmi $$(docker images -q -f dangling=true)
	-docker rmi $$(docker images --format '{{.Repository}}:{{.Tag}}' | grep '$(IMAGE_NAME)')

push:
	docker push $(IMAGE_NAME)
