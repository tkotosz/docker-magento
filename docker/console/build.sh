#!/bin/sh

VERSION="${1:-latest}"
NAME="php8.1-cli-alpine-magento-dev"

docker build --build-arg XDEBUG=0 --tag tkotosz/$NAME:$VERSION .
docker build --build-arg XDEBUG=1 --tag tkotosz/$NAME-debug:$VERSION .

docker push tkotosz/$NAME:$VERSION
docker push tkotosz/$NAME-debug:$VERSION
