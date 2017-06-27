REGISTRY := quay.io
NAMESPACE := lukebond
CONTAINER_NAME := git-crypt
VERSION := v1.0.0
CONTAINER_TAG = ${REGISTRY}/${NAMESPACE}/${CONTAINER_NAME}:$(VERSION)
IMAGE_FILENAME = $(CONTAINER_NAME).tar
GITREF  = $(shell git show --oneline -s | head -n 1 | awk '{print $$1}')

.PHONY: all build save clean

build:
	docker build -t $(CONTAINER_TAG) --build-arg BUILDDATE=`date -u +%Y-%m-%dT%H:%M:%SZ` --build-arg VERSION=$(VERSION) --build-arg VCSREF=$(GITREF) .

save:
	docker save $(CONTAINER_TAG) -o $(IMAGE_FILENAME)
	chmod +r $(IMAGE_FILENAME)

clean:
	docker rmi $(CONTAINER_TAG)
