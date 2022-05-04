#!/bin/sh

set -ex

PROJECT_HOST="docker-test-project.local"

docker-compose down --remove-orphans --volumes
docker-compose up -d --remove-orphans --build
sleep 1
docker-compose ps

docker-compose exec --user=appuser console ./install-magento.sh $PROJECT_HOST

echo "127.0.0.1 ::1 $PROJECT_HOST" | sudo tee -a /etc/hosts