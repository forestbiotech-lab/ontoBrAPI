#!/usr/bin/env bash
set -e 

cd
mkdir git
cd git
git clone https://github.com/forestbiotech-lab/ontoBrAPI.git
cd ontoBrAPI
git submodule init
git submodule set-url ontoBrAPI-node-docker  https://github.com/forestbiotech-lab/ontoBrAPI-node-docker.git
git submodule set-url ontobrapi-admin  https://github.com/forestbiotech-lab/ontobrapi-admin.git
git submodule set-url ontobrapi-brapi  https://github.com/forestbiotech-lab/ontobrapi-brapi.git
git submodule update
cd ontoBrAPI-node-docker
git checkout master
git pull origin master
cd ../ontobrapi-admin
git checkout main
cd ../ontobrapi-brapi
git checkout master
cd ..
git submodule sync

sed -ri "s:3001\:80:80\:80:g" docker-compose.yml

docker-compose up -d

exit 0
