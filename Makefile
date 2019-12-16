#!make

ifneq ("$(wildcard $(CURDIR)/.env)","")
	include $(CURDIR)/.env
	export $(shell sed 's/=.*//' .env)
endif

# Allow override for moby or another runtime
export DOCKER ?= docker

export MKDIR ?= mkdir

# Allow additional options such as --squash
# DOCKER_BUILD_ARGS ?= 

DIST_DIR := $(CURDIR)/dist

export REQUIREMENTS_FILE ?= requirements.txt

export ARCH := $(shell ${DOCKER} run ${DOCKER_RUN_ARGS} --rm busybox uname -m)

export OPENCV_GIT_VERSION ?= 4.1.2
export OPENCV_DIST_IMAGE ?= opencv-dist/$(OPENCV_GIT_VERSION)-$(ARCH)
export OPENCV_BUILDER_TAG ?= opencv-builder-$(OPENCV_GIT_VERSION)-$(ARCH)
export OPENCV_DOCKERFILE ?= opencv.Dockerfile

export WHEELHOUSE_DOCKERFILE ?= wheelhouse.Dockerfile
export WHEELHOUSE_TAG ?= app-wheelhouse-$(ARCH)

export DEPENDENCIES_DOCKERFILE ?= dependencies.Dockerfile

export APPBASE_DOCKERFILE ?= app-base.Dockerfile
export APPBASE_TAG ?= app-base-$(ARCH)
#export APP_BASE_IMAGE ?= arm32v7/python:3.7.5-buster-slim
export APP_BASE_IMAGE ?= python:3.7.5-slim-buster

export APP_DOCKERFILE ?= Dockerfile
export APP_TAG ?= app-$(ARCH)

wheelhouse:
	$(DOCKER) build $(DOCKER_BUILD_ARGS) \
					--build-arg IMAGE=$(APP_BASE_IMAGE) \
					--build-arg REQUIREMENTS_FILE=$(REQUIREMENTS_FILE) \
					-t $(WHEELHOUSE_TAG) \
					-f $(CURDIR)/$(WHEELHOUSE_DOCKERFILE) \
					.

app-base:
	$(DOCKER) build $(DOCKER_BUILD_ARGS) \
					--squash \
					--build-arg IMAGE=$(APP_BASE_IMAGE) \
					--build-arg OPENCV_DEPENDENCIES=$(OPENCV_DIST_IMAGE) \
					--build-arg WHEELHOUSE=$(WHEELHOUSE_TAG) \
					-t $(APPBASE_TAG) \
					-f $(CURDIR)/$(APPBASE_DOCKERFILE) \
					.

app:
	$(DOCKER) build $(DOCKER_BUILD_ARGS) \
					--build-arg IMAGE=$(APPBASE_TAG) \
					-t $(APP_TAG) \
					-f $(CURDIR)/$(APP_DOCKERFILE) \
					.

opencv-dist:
	echo "Building $(OPENCV_BUILDER_TAG)"
	$(DOCKER) build $(DOCKER_BUILD_ARGS) \
					--build-arg OPENCV_GIT_VERSION=$(OPENCV_GIT_VERSION) \
					--build-arg IMAGE=$(APP_BASE_IMAGE) \
					-t $(OPENCV_BUILDER_TAG) \
					-f $(CURDIR)/$(OPENCV_DOCKERFILE) \
					.

	$(MKDIR) -p $(DIST_DIR)
	rm -f $(OPENCV_BUILDER_TAG).cid

	$(DOCKER) run --cidfile $(OPENCV_BUILDER_TAG).cid $(OPENCV_BUILDER_TAG)

	$(DOCKER) cp $$(cat $(OPENCV_BUILDER_TAG).cid):/opencv/build/OpenCV-$(OPENCV_GIT_VERSION)-$(ARCH)-dev.deb $(DIST_DIR)
	$(DOCKER) cp $$(cat $(OPENCV_BUILDER_TAG).cid):/opencv/build/OpenCV-$(OPENCV_GIT_VERSION)-$(ARCH)-libs.deb $(DIST_DIR) 
	$(DOCKER) cp $$(cat $(OPENCV_BUILDER_TAG).cid):/opencv/build/OpenCV-$(OPENCV_GIT_VERSION)-$(ARCH)-licenses.deb $(DIST_DIR)
	$(DOCKER) cp $$(cat $(OPENCV_BUILDER_TAG).cid):/opencv/build/OpenCV-$(OPENCV_GIT_VERSION)-$(ARCH)-main.deb $(DIST_DIR)
	$(DOCKER) cp $$(cat $(OPENCV_BUILDER_TAG).cid):/opencv/build/OpenCV-$(OPENCV_GIT_VERSION)-$(ARCH)-python.deb $(DIST_DIR)
	$(DOCKER) cp $$(cat $(OPENCV_BUILDER_TAG).cid):/opencv/build/OpenCV-$(OPENCV_GIT_VERSION)-$(ARCH)-scripts.deb $(DIST_DIR)

	# Leaving these here in case we want to use them in the future. I'd normally delete these, but they aren't very discoverable.
	#$(DOCKER) cp $$(cat $(OPENCV_BUILDER_TAG).cid):/opencv/build/OpenCV-$(OPENCV_GIT_VERSION)-$(ARCH).sh $(DIST_DIR)
	#$(DOCKER) cp $$(cat $(OPENCV_BUILDER_TAG).cid):/opencv/build/OpenCV-$(OPENCV_GIT_VERSION)-$(ARCH).tar.Z $(DIST_DIR)
	#$(DOCKER) cp $$(cat $(OPENCV_BUILDER_TAG).cid):/opencv/build/OpenCV-$(OPENCV_GIT_VERSION)-$(ARCH).tar.gz $(DIST_DIR)

	$(DOCKER) build $(DOCKER_BUILD_ARGS) \
				--build-arg IMAGE=$(APP_BASE_IMAGE) \
				-t $(OPENCV_DIST_IMAGE) \
				-f $(CURDIR)/$(DEPENDENCIES_DOCKERFILE) \
				./dist/

	$(DOCKER) rm $$(cat $(OPENCV_BUILDER_TAG).cid) && rm $(OPENCV_BUILDER_TAG).cid
	$(DOCKER) image rm $(OPENCV_BUILDER_TAG)
