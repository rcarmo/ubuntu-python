IMAGENAME=ubuntu-python

3.6: 3.6/Dockerfile
	docker build -t rcarmo/$(IMAGENAME):3.6 3.6
	docker build -t rcarmo/$(IMAGENAME):3.6-onbuild 3.6/onbuild
	docker tag rcarmo/$(IMAGENAME):3.6 rcarmo/$(IMAGENAME):3.6.3
	docker tag rcarmo/$(IMAGENAME):3.6 rcarmo/$(IMAGENAME):latest

push:
	docker push rcarmo/$(IMAGENAME)
