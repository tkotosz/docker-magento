#!/bin/sh

VERSION="${1:-latest}"
NAME="varnish7-magento-dev"

docker build --tag tkotosz/$NAME:$VERSION .

docker push tkotosz/$NAME:$VERSION
