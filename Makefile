################################################################
# Backpacker: Makefile for building Packer-based machine images
# https://github.com/cliffano/backpacker
################################################################

# Backpacker's version number
BACKPACKER_VERSION = 1.0.0

################################################################
# User configuration variables
# These variables should be stored in backpacker.yml config file,
# and they will be parsed using yq https://github.com/mikefarah/yq
# Example:
# ---
# image:
#   name: someimage
#   version: 1.2.3
# author: Some Author
# dockerhub:
#   username: someuser

# IMAGE_NAME is the name of the machine image
IMAGE_NAME=$(shell yq .image.name backpacker.yml)

# IMAGE_VERSION is the version of the machine image
IMAGE_VERSION=$(shell yq .image.version backpacker.yml)

# AUTHOR is the author of the Python package
AUTHOR ?= $(shell yq .author backpacker.yml)

# DOCKERHUB_USERNAME is the username of Docker Hub account to publish the Docker machine image to
DOCKERHUB_USERNAME ?= $(shell yq .dockerhub.username backpacker.yml)

$(info ################################################################)
$(info Building Python package using backpacker with user configurations:)
$(info - Image name: ${IMAGE_NAME})
$(info - Author: ${AUTHOR})

define python_venv
	. .venv/bin/activate && $(1)
endef

################################################################
# Base targets

# CI target to be executed by CI/CD tool
all:ci
ci: clean deps lint build-docker test-docker

# Ensure stage directory exists
stage:
	mkdir -p logs

# Remove all temporary (staged, generated, cached) files
clean:
	rm -rf logs/

# Retrieve the Pyhon package and Packer plugin dependencies
deps:
	python3 -m venv .venv
	$(call python_venv,python3 -m pip install -r requirements.txt)
	packer plugins install github.com/hashicorp/docker 1.1.1
	packer plugins install github.com/hashicorp/ansible 1.1.3

deps-upgrade:
	python3 -m venv .venv
	$(call python_venv,python3 -m pip install -r requirements-dev.txt)
	$(call python_venv,pip-compile --upgrade)

deps-extra-apt:
	apt-get update
	apt-get install -y python3-venv

rmdeps:
	rm -rf .venv/

# Update Makefile to the latest version tag
update-to-latest: TARGET_BACKPACKER_VERSION = $(shell curl -s https://api.github.com/repos/cliffano/backpacker/tags | jq -r '.[0].name')
update-to-latest: update-to-version

# Update Makefile to the main branch
update-to-main:
	curl https://raw.githubusercontent.com/cliffano/backpacker/main/src/Makefile-backpacker -o Makefile

# Update Makefile to the version defined in TARGET_BACKPACKER_VERSION parameter
update-to-version:
	curl https://raw.githubusercontent.com/cliffano/backpacker/$(TARGET_BACKPACKER_VERSION)/src/Makefile-backpacker -o Makefile

################################################################
# Testing targets

lint:
	packer validate -syntax-only templates/packer/docker.pkr.hcl
	$(call python_venv,ansible-lint provisioners/ansible/*.yaml)
	$(call python_venv,yamllint conf/ansible/*.yaml provisioners/ansible/*.yaml)
	find conf/ -type f -name "*.json" | while IFS= read -r file; do echo "> $$file"; python3 -m json.tool "$$file"; done
	# shellcheck provisioners/shell/*.sh

test: test-docker

test-docker:
	$(call python_venv,py.test -v test/testinfra/docker.py)

################################################################
# Release targets

release-major:
	rtk release --release-increment-type major

release-minor:
	rtk release --release-increment-type minor

release-patch:
	rtk release --release-increment-type patch

################################################################
# Image building and publishing targets

build-docker: stage
	PACKER_LOG_PATH=logs/packer-$@.log \
		PACKER_LOG=1 \
		PACKER_TMP_DIR=/tmp \
		packer build \
		-var-file=conf/packer/docker.json \
		-var 'version=$(IMAGE_VERSION)' \
		templates/packer/docker.pkr.hcl

publish-docker:
	docker image push $(DOCKERHUB_USERNAME)/$(IMAGE_NAME):latest
	docker image push $(DOCKERHUB_USERNAME)/$(IMAGE_NAME):$(IMAGE_VERSION)

################################################################

.PHONY: all ci clean stage deps lint build-docker test test-docker publish-docker release-major release-minor release-patch