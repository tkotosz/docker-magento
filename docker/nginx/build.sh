#!/bin/sh

VERSION="${1:-latest}"
NAME="nginx1.24-alpine-magento-dev"

docker build --tag tkotosz/$NAME:$VERSION .

docker push tkotosz/$NAME:$VERSION
