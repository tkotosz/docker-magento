#!/bin/sh

set -ex

PROJECT_HOST=$1

composer create-project --no-install --repository=https://repo.magento.com/ magento/project-community-edition=2.4.4 /tmp/magento
cp -R /tmp/magento/* .
rm -rf /tmp/magento
composer install
bin/magento setup:install --admin-email "foobar@gmail.com" --admin-firstname "admin" --admin-lastname "admin" --admin-password "admin123" --admin-user "admin" --backend-frontname "admin" --base-url "https://$PROJECT_HOST/" --use-rewrites 1 --use-secure 1 --db-host "database" --db-name "magentodb" --db-user "magento" --db-password "magento" --session-save "redis" --session-save-redis-host "redis-session" --session-save-redis-port 6379 --session-save-redis-db 1 --cache-backend "redis" --cache-backend-redis-server "redis-cache" --cache-backend-redis-port 6379 --cache-backend-redis-db 2 --page-cache "redis" --page-cache-redis-server "redis-cache" --page-cache-redis-port 6379 --page-cache-redis-db 3 --search-engine "elasticsearch7" --elasticsearch-host "elasticsearch" --elasticsearch-port 9200 --amqp-host "rabbitmq" --amqp-port 5672 --amqp-user "rabbit_magento" --amqp-password "rabbit_magento" --amqp-virtualhost "rabbit_magento" --http-cache-hosts "varnish:80"
bin/magento setup:upgrade
bin/magento config:set --scope=default --scope-code=0 system/full_page_cache/caching_application 2
bin/magento cache:clean