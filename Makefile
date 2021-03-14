# default build target
all::

all:: pre build
.PHONY: all test

MAINTAINER:="Evan Sarmiento <esarmien@snkattck.co>"
MAINTAINER_URL:="https://github.com/snkattck/slurm-docker-cluster"
IMAGE_NAME:=snkattck/slurm-docker-cluster
GIT_SHA:=$(shell git rev-parse HEAD)
OS:=$(shell uname | tr '[:upper:]' '[:lower:]')
GIT_BRANCH:=$(shell git rev-parse --abbrev-ref HEAD)
CONTAINER_TEST_VERSION:=1.8.0
export PATH:=$(PWD)/test/test_helper/bats-core/bin:$(PATH)

# Check Make version (we need at least GNU Make 3.82). Fortunately,
# 'undefine' directive has been introduced exactly in GNU Make 3.82.
ifeq ($(filter undefine,$(value .FEATURES)),)
$(error Unsupported Make version. \
    The build system does not work properly with GNU Make $(MAKE_VERSION), \
    please use GNU Make 3.82 or above.)
endif

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

push:
	docker push $(IMAGE_NAME):$(PREFIX)
	docker tag $(IMAGE_NAME):$(PREFIX) $(IMAGE_TAG)
	docker push $(IMAGE_TAG)

test:
	docker-compose up -d
	mkdir ./test-results
	bats -F junit -o ./test-results ./test
	docker-compose down -v