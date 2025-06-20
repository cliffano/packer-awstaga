#!/bin/sh
set -o errexit
set -o nounset

apk add ansible
pip3 install packaging