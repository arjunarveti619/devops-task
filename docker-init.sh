#!/bin/sh

set -eu

# Docker
sudo apt remove --yes docker docker-engine docker.io \
    && sudo apt update \
    && sudo apt --yes --no-install-recommends install \
        apt-transport-https \
        ca-certificates \
    && wget --quiet --output-document=- https://download.docker.com/linux/ubuntu/gpg \
        | sudo apt-key add - \
    && sudo add-apt-repository \
        "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu \
        $(lsb_release --codename --short) \
        stable" \
    && sudo apt update \
    && sudo apt --yes --no-install-recommends install docker-ce \

#Jenkins
sudo docker pull arjunarveti/myjenkins:v5

export CONFIG_FOLDER=$PWD/config
mkdir $CONFIG_FOLDER
chown 1000 $CONFIG_FOLDER

sudo docker run -d -p 8080:8080 -p 50000:50000  -v /var/run/docker.sock:/var/run/docker.sock -v $CONFIG_FOLDER:/var/jenkins_home:z arjunarveti/myjenkins:v5

#Install Ansible
sudo apt install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install ansible