#!make

# Allow override for moby or another runtime
export DOCKER ?= docker

export MKDIR ?= mkdir

# Allow additional options such as --squash
# DOCKER_BUILD_ARGS ?= 

DIST_DIR := $(CURDIR)/dist

export OPENCV_GIT_VERSION ?= 4.1.2
export OPENCV_DIST_IMAGE ?= opencv-dist/$(OPENCV_GIT_VERSION)
export OPENCV_DOCKERFILE ?= opencv.Dockerfile
export WHEELHOUSE_DOCKERFILE ?= wheelhouse.Dockerfile
export WHEELHOUSE_TAG ?= app-wheelhouse
export DEPENDENCIES_DOCKERFILE ?= dependencies.Dockerfile
export APP_DOCKERFILE ?= Dockerfile
export APP_TAG ?= demo-app
export IMAGE ?= arm32v7/python:3.7.5-slim-buster
export ARCH := $(shell ${DOCKER} run ${DOCKER_RUN_ARGS} --rm busybox uname -m)

wheelhouse:
	$(DOCKER) build $(DOCKER_BUILD_ARGS) \
					--build-arg IMAGE=$(IMAGE) \
					-t $(WHEELHOUSE_TAG) \
					-f $(CURDIR)/$(WHEELHOUSE_DOCKERFILE) \
					.

app:
	$(DOCKER) build $(DOCKER_BUILD_ARGS) \
					--squash \
					--build-arg IMAGE=$(IMAGE) \
					--build-arg OPENCV_DEPENDENCIES=$(OPENCV_DIST_IMAGE) \
					--build-arg WHEELHOUSE=$(WHEELHOUSE_TAG) \
					-t $(APP_TAG) \
					-f $(CURDIR)/$(APP_DOCKERFILE) \
					.

opencv:
	$(eval TAG:=opencv-$(OPENCV_GIT_VERSION)-builder)
	echo "Building OpenCV-$(OPENCV_GIT_VERSION)-$(ARCH).sh"
	$(DOCKER) build $(DOCKER_BUILD_ARGS) \
					--build-arg OPENCV_GIT_VERSION=$(OPENCV_GIT_VERSION) \
					--build-arg IMAGE=$(IMAGE) \
					-t $(TAG) \
					-f $(CURDIR)/$(OPENCV_DOCKERFILE) \
					.

	$(MKDIR) -p $(DIST_DIR)
	rm -f $(TAG).cid

	$(DOCKER) run --cidfile $(TAG).cid $(TAG)

	$(DOCKER) cp $$(cat $(TAG).cid):/opencv/build/OpenCV-$(OPENCV_GIT_VERSION)-$(ARCH)-dev.deb $(DIST_DIR)
	$(DOCKER) cp $$(cat $(TAG).cid):/opencv/build/OpenCV-$(OPENCV_GIT_VERSION)-$(ARCH)-libs.deb $(DIST_DIR) 
	$(DOCKER) cp $$(cat $(TAG).cid):/opencv/build/OpenCV-$(OPENCV_GIT_VERSION)-$(ARCH)-licenses.deb $(DIST_DIR)
	$(DOCKER) cp $$(cat $(TAG).cid):/opencv/build/OpenCV-$(OPENCV_GIT_VERSION)-$(ARCH)-main.deb $(DIST_DIR)
	$(DOCKER) cp $$(cat $(TAG).cid):/opencv/build/OpenCV-$(OPENCV_GIT_VERSION)-$(ARCH)-python.deb $(DIST_DIR)
	$(DOCKER) cp $$(cat $(TAG).cid):/opencv/build/OpenCV-$(OPENCV_GIT_VERSION)-$(ARCH)-scripts.deb $(DIST_DIR)
	$(DOCKER) cp $$(cat $(TAG).cid):/opencv/build/OpenCV-$(OPENCV_GIT_VERSION)-$(ARCH).sh $(DIST_DIR)
	$(DOCKER) cp $$(cat $(TAG).cid):/opencv/build/OpenCV-$(OPENCV_GIT_VERSION)-$(ARCH).tar.Z $(DIST_DIR)
	$(DOCKER) cp $$(cat $(TAG).cid):/opencv/build/OpenCV-$(OPENCV_GIT_VERSION)-$(ARCH).tar.gz $(DIST_DIR)

	$(DOCKER) build $(DOCKER_BUILD_ARGS) \
				--build-arg IMAGE=$(IMAGE) \
				-t $(OPENCV_DIST_IMAGE) \
				-f $(CURDIR)/$(DEPENDENCIES_DOCKERFILE) \
				./dist/

	$(DOCKER) rm $$(cat $(TAG).cid) && rm $(TAG).cid
	$(DOCKER) image rm $(TAG)
