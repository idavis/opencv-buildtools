#!make

include $(CURDIR)/.env
export $(shell sed 's/=.*//' .env)

# Allow override for moby or another runtime
export DOCKER ?= docker

export MKDIR ?= mkdir

# Allow additional options such as --squash
# DOCKER_BUILD_ARGS ?= 

DIST_DIR := $(CURDIR)/dist

export OPENCV_GIT_VERSION
export DOCKERFILE ?= Dockerfile.bionic
export CUDA_ARCH_BIN := 3.0;3.5;3.7;5.0;5.2;6.0;6.1;7.0;7.5
export IMAGE ?= INVALID
export TAG ?= INVALID

set-opencv-4.0.1:
	$(eval OPENCV_GIT_VERSION:=4.0.1)

10.0-cudnn7-devel-ubuntu18.04:
	$(eval IMAGE:=nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04)

build-cuda:
	$(eval TAG:=opencv-$(OPENCV_GIT_VERSION)-builder)
	
	$(DOCKER) build $(DOCKER_BUILD_ARGS) \
					--build-arg IMAGE=$(IMAGE) \
					--build-arg OPENCV_GIT_VERSION=$(OPENCV_GIT_VERSION) \
					--build-arg CUDA_ARCH_BIN="$(CUDA_ARCH_BIN)" \
					-t $(TAG) \
					-f $(CURDIR)/$(DOCKERFILE) \
					$(DOCKER_CONTEXT)

	$(MKDIR) -p $(DIST_DIR)
	rm -f $(TAG).cid
	$(DOCKER) run --cidfile $(TAG).cid $(TAG)
	# TODO: replace x86_64 with something like:
	#     "$(${DOCKER} run ${DOCKER_RUN_ARGS} --rm busybox uname -m)"
	$(DOCKER) cp $$(cat $(TAG).cid):/opencv/build/OpenCV-$(OPENCV_GIT_VERSION)-x86_64.sh $(DIST_DIR)
	$(DOCKER) rm $$(cat $(TAG).cid) && rm $(TAG).cid
	$(DOCKER) image rm $(TAG)

opencv-4.0.1-10.0-cudnn7-devel-ubuntu18.04: | set-opencv-4.0.1 10.0-cudnn7-devel-ubuntu18.04 build-cuda
