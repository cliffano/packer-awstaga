version ?= 0.9.0-pre.0

ci: clean deps lint build-docker test-docker

clean:
	rm -rf logs

stage:
	mkdir -p logs

deps:
	pip3 install -r requirements.txt

lint:
	packer validate -syntax-only $(VAR_PARAMS) templates/packer/docker.json
	# ansible-lint provisioners/ansible/playbook/*.yaml
	shellcheck provisioners/*.sh
	yamllint conf/ansible/inventory/group_vars/*.yaml provisioners/ansible/playbook/*.yaml
	jsonlint conf/packer/vars/*.json templates/packer/*.json

build-docker: stage
	PACKER_LOG_PATH=logs/packer-$@.log \
		PACKER_LOG=1 \
		PACKER_TMP_DIR=/tmp \
		packer build \
		$(VAR_PARAMS) \
		-var-file=conf/packer/vars/docker.json \
		-var 'version=$(version)' \
		templates/packer/docker.json

test-docker:
	py.test -v test/testinfra/docker.py

publish-docker:
	docker image push cliffano/awstaga:latest
	docker image push cliffano/awstaga:$(version)

release-major:
	awstaga release --release-increment-type major

release-minor:
	awstaga release --release-increment-type minor

release-patch:
	awstaga release --release-increment-type patch

.PHONY: ci clean stage deps lint build-docker test-docker publish-docker release-major release-minor release-patch
