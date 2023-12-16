<img align="right" src="https://raw.github.com/cliffano/packer-awstaga/master/avatar.jpg" alt="Avatar"/>

[![Build Status](https://github.com/cliffano/packer-awstaga/workflows/CI/badge.svg)](https://github.com/cliffano/packer-awstaga/actions?query=workflow%3ACI)
[![Docker Pulls Count](https://img.shields.io/docker/pulls/cliffano/awstaga.svg)](https://hub.docker.com/r/cliffano/awstaga/)
[![Security Status](https://snyk.io/test/github/cliffano/packer-awstaga/badge.svg)](https://snyk.io/test/github/cliffano/packer-awstaga)

Packer Awstaga
--------------

Packer Awstaga is a Packer builder of machine image for running [Awstaga](https://github.com/cliffano/awstaga) software release tool.

| Packer Awstaga Version | Awstaga Version | Python Version | Alpine Version |
|------------------------|-----------------|----------------|----------------|
| 1.3.0                  | 1.2.1           | 3.12.1         | 3.19           |
| 1.2.0                  | 1.2.0           | 3.12.0         | 3.18           |
| 1.1.0                  | 1.1.0           | 3.12.0         | 3.18           |
| 1.0.0                  | 1.0.0           | 3.12.0         | 3.18           |
| 0.11.0                 | 0.12.0          | 3.12.0         | 3.18           |
| 0.10.0                 | 0.11.0          | 3.11.4         | 3.18           |

Installation
------------

Pull awstaga Docker image from Docker Hub:

    docker pull cliffano/awstaga

Or alternatively, you can create the Docker image:

    git clone https://github.com/cliffano/packer-awstaga
    cd packer-awstaga
    make build-docker

An image with `cliffano/awstaga` repository and `latest` tag should show up:

    haku> docker images

    REPOSITORY                                       TAG                 IMAGE ID            CREATED             SIZE
    cliffano/awstaga                                0.9.0-pre.0                             cfabed5d3162   2 minutes ago   593MB
    cliffano/awstaga                                latest                                  cfabed5d3162   2 minutes ago   593MB

Usage
-----

Simply run a container using cliffano/awstaga image:

    docker run \
      --rm \
      --workdir /opt/workspace \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v $(pwd):/opt/workspace \
      -i -t cliffano/awstaga

Alternatively, if you want to run the container via Docker Compose, you can have this in the configuration:

    awstaga:
      image: cliffano/awstaga
      volumes:
        - "${PWD}:/src"
      working_dir: "/src"

and then run Docker Compose:

    docker-compose run \
      --rm \
      awstaga --conf-file awstaga.yaml
