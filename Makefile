# default build target
all::

all:: build
.PHONY: all push test

MAINTAINER:="Evan Sarmiento <esarmien@snkattck.co>"
MAINTAINER_URL:="https://github.com/snkattck/slurm-docker-cluster"
IMAGE_NAME:=snkattck/slurm-docker-cluster
SLURM_TAG:=slurm-20-02-1-1
GIT_SHA:=$(shell git rev-parse HEAD)
OS:=$(shell uname | tr '[:upper:]' '[:lower:]')
GIT_BRANCH:=$(shell git rev-parse --abbrev-ref HEAD)
CONTAINER_TEST_VERSION:=1.8.0

ifeq ($(GIT_BRANCH), master)
	IMAGE_TAG:=$(IMAGE_NAME):$(SLURM_TAG)-$(GIT_SHA)
	PREFIX:=$(SLURM_TAG)
else
	IMAGE_TAG:=$(IMAGE_NAME):$(SLURM_TAG)-$(GIT_BRANCH)-$(GIT_SHA)
	PREFIX:=$(SLURM_TAG)-$(GIT_BRANCH)
endif

GIT_DATE:="$(shell TZ=UTC git show --quiet --date='format-local:%Y-%m-%d %H:%M:%S +0000' --format='%cd')"
BUILD_DATE:="$(shell date -u '+%Y-%m-%d %H:%M:%S %z')"

build:

	# "base" image
	docker build \
		--pull \
		--build-arg SLURM_TAG=$(SLURM_TAG) \
		--build-arg MAINTAINER=$(MAINTAINER) \
		--build-arg MAINTAINER_URL=$(MAINTAINER_URL) \
		--build-arg GIT_SHA="$(GIT_SHA)" \
		--build-arg GIT_DATE=$(GIT_DATE) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--tag $(IMAGE_TAG) \
		--tag $(IMAGE_NAME):$(PREFIX) \
		--file Dockerfile .
