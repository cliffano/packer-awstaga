#!/bin/bash
docker --version
source /home/.virtualenvs/py36/bin/activate
make clean deps lint build-docker
cat logs/packer-docker.log
echo "${DOCKERHUB_TOKEN}" | docker login --username cliffano --password-stdin
docker inspect cliffano/awstaga
make publish-docker