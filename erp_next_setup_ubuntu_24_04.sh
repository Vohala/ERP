#!/bin/bash

## INSTALL GIT ##
sudo apt install git


## INSTALL DOCKER ##

# uninstall old/incompatible docker versions
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install latest Docker Engine version
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify installation
sudo docker run hello-world


## ENSURE DOCKER RUNS WITHOUT SUDO ##

# Create Docker Group
sudo groupadd docker

# Add your user to Docker group
sudo usermod -aG docker $USER

# Activate group changes
newgrp docker

# Verify that you can run docker commands without sudo
docker run hello-world


## CLONE FRAPPE_DOCKER GIT REPO ##

git clone https://github.com/frappe/frappe_docker
cd frappe_docker


## RUN FRAPPE_DOCKER DEFAULT CONTAINER ##

docker compose -f pwd.yml up -d
