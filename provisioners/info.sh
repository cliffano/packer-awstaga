#!/bin/sh
set -o errexit
set -o nounset

echo "Python path: $(command -v python3)"
echo "Ansible path: $(command -v ansible)"
echo "Awstaga path: $(command -v awstaga)"

echo "Python version: $(python3 --version)"
echo "Ansible version: $(ansible --version)"
echo "Awstaga version: $(awstaga --version)"
