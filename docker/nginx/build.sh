#!/bin/sh

VERSION="${1:-latest}"
NAME="nginx1.19-alpine-magento-dev"

docker build --tag tkotosz/$NAME:$VERSION .

docker push tkotosz/$NAME:$VERSION
