#!/bin/sh

#set -eu

sudo apt-get update

#Install docker only if not installed
docker --version | grep 'command not found' &> /dev/null
if [ $? == 0 ]; then
   echo "matched"
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
        && sudo apt --yes --no-install-recommends install docker-ce

fi

#Stop all the running containers
ids=$(sudo docker ps -q)
for id in $ids
do
  echo "$id"
  sudo docker stop $id && sudo docker rm $id
done


#Deploy latest Spring petclinic app
sudo docker pull arjunarveti/spring-petclinic
sudo docker run -d -p 8080:8080 arjunarveti/spring-petclinic