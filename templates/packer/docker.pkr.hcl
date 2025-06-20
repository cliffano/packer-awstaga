packer {
  required_plugins {
    docker = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/docker"
    }
    ansible = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "docker_source" {
  type    = string
  default = ""
}

variable "tmp_dir" {
  type    = string
  default = "/tmp/packer-awstaga"
}

variable "version" {
  type    = string
  default = "x.x.x"
}

source "docker" "studio" {
  image  = var.docker_source
  commit = true
  run_command = [
    "--privileged",
    "-e",
    "container=docker",
    "-v",
    "/sys/fs/cgroup:/sys/fs/cgroup",
    "-d",
    "-i",
    "-t",
    "{{.Image}}",
  ]
  changes = [
    "ENV LANG en_US.UTF-8",
    "ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    "ENTRYPOINT [\"awstaga\"]"
  ]
}

build {
  sources = [
    "source.docker.studio"
  ]

  name = "studio"

  provisioner "shell" {
    inline = [
      "mkdir -p ${var.tmp_dir}"
    ]
  }

  provisioner "shell" {
    script = "provisioners/shell/init.sh"
  }

  provisioner "ansible-local" {
    playbook_file = "provisioners/ansible/awstaga.yaml"
    group_vars = "conf/ansible/"
    inventory_groups = ["defaults"]
  }

  provisioner "shell" {
    script = "provisioners/shell/info.sh"
  }

  post-processor "docker-tag" {
    repository = "cliffano/awstaga"
    tags        = [
      "latest",
      var.version
    ]
  }
}
