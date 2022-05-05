# Magento 2 Docker Environment

## Environment Setup

### For new project
```bash
git clone git@github.com:tkotosz/docker-magento.git docker-magento-demo
cd docker-magento-demo
docker-compose up -d --remove-orphans
docker-compose exec --user=appuser console bash
composer create-project --no-install --repository=https://repo.magento.com/ magento/project-community-edition=2.4.4 /tmp/magento
cp -R /tmp/magento/* .
rm -rf /tmp/magento
composer install
bin/magento setup:install --admin-email "foobar@gmail.com" --admin-firstname "admin" --admin-lastname "admin" --admin-password "admin123" --admin-user "admin" --backend-frontname "admin" --base-url "https://docker-test-project.local/" --use-rewrites 1 --use-secure 1 --db-host "database" --db-name "magentodb" --db-user "magento" --db-password "magento" --session-save "redis" --session-save-redis-host "redis-session" --session-save-redis-port 6379 --session-save-redis-db 1 --cache-backend "redis" --cache-backend-redis-server "redis-cache" --cache-backend-redis-port 6379 --cache-backend-redis-db 2 --page-cache "redis" --page-cache-redis-server "redis-cache" --page-cache-redis-port 6379 --page-cache-redis-db 3 --search-engine "elasticsearch7" --elasticsearch-host "elasticsearch" --elasticsearch-port 9200 --amqp-host "rabbitmq" --amqp-port 5672 --amqp-user "rabbit_magento" --amqp-password "rabbit_magento" --amqp-virtualhost "rabbit_magento" --http-cache-hosts "varnish:80"
bin/magento setup:upgrade
bin/magento config:set --scope=default --scope-code=0 system/full_page_cache/caching_application 2
bin/magento cache:clean
```

### For existing project
```bash
git clone <yourproject> docker-test-project
git clone git@github.com:tkotosz/docker-magento.git docker-magento
rm -rf docker-magento/.git docker-magento/.gitignore
cp -R docker-magento/* docker-test-project/
rm -rf docker-magento
cp docker-test-project/docker/env.php.sample docker-test-project/app/etc/env.php
cp ~/.composer/auth.json docker-test-project/auth.json
cd docker-test-project
docker-compose up -d --remove-orphans
docker-compose exec --user=appuser console bash
composer install
zcat magento.sql.gz | mysql -uroot -proot -hdatabase magentodb
mysql -uroot -proot -hdatabase magentodb -e "update core_config_data set value='https://docker-test-project.local/' where path like '%/base_url';"
mysql -uroot -proot -hdatabase magentodb -e "delete from core_config_data where path like '%admin/url/%'"
bin/magento setup:upgrade
bin/magento config:set --scope=default --scope-code=0 system/full_page_cache/caching_application 2
bin/magento cache:clean
```

### Add hosts file entry
```bash
echo "127.0.0.1 ::1 docker-test-project.local" | sudo tee -a /etc/hosts
```

## Environment Details

### nginx-tls-offload service

Uses: nginx 1.19
Purpose:
Listen on host port 80 (http) and 443 (https) and forward the incoming requests to the varnish service.
This service is needed because varnish does not support https, so TLS-offload required before passing the incoming request to it.
See more details [here](https://github.com/varnish/docker-varnish#tls).

### varnish service

Uses: varnish 6
Purpose: Reverse-proxy full page cache. On cache-miss passes the request to the nginx service.

### nginx service

Uses: nginx 1.19
Purpose: Main webserver passes requests to the php-fpm or php-fpm-debug service based on XDEBUG_SESSION cookie.

### php-fpm service

Uses: php-fpm 7.4
Purpose: Main FastCGI backend, receives requests from the nginx service in non-debug mode.

### php-fpm-debug service

Uses: php-fpm 7.4
Purpose: Debug FastCGI backend, receives requests from the nginx service in debug-mode.

### database service

Uses: mysql 8.0
Purpose: Database

### elasticsearch service

Uses: elasticsearch 7.12.1
Purpose: Search engine

### redis-cache service

Uses: redis 6
Purpose: Cache backend for all caches except FPC (FPC replaced by varnish reverse-proxy).

### redis-session service

Uses: redis 6
Purpose: Cache backend for sessions

### rabbitmq service

Uses: rabbitmq 3.8
Purpose: Message broker for "async" operations.

### mailhog service

Uses: mailhog 1.0.1
Purpose: Catches outgoing emails.

### console service

Uses: php cli 7.4
Purpose: Development console, you can run composer, bin/magento, etc in it in non-debug mode.

### console-debug service

Uses: php cli 7.4
Purpose: Development console, you can run composer, bin/magento, etc in it in debug mode.

## How to use xdebug

### Xdebug for HTTP requests

The docker environment comes with 2 php-fpm containers (php-fpm and php-fpm-debug).
The default one does not have xdebug installed to be as fast as possible while the debug one has all the necessary configurations for xdebug.
The nginx service is configured to route requests to the default php-fpm container normally BUT if you have an XDEBUG_SESSION cookie then it forwards the request through the debug php-fpm container.
In addition to all this varnish is configured to pass to the backend if the XDEBUG_SESSION cookie exists, therefore during debugging you don't have to worry about full page caching because it is essentially disabled.

The above setup makes it easy to toggle the debug session from the browser using the [XDEBUG helper browser extension](https://chrome.google.com/webstore/detail/xdebug-helper/eadndfjplgieldjbigjakmdgkmoaaaoc?hl=en).
This extension is responsible to create/remove the xdebug cookie mentioned above. So make sure to install it.

Configuration:
1. Install the [XDEBUG helper browser extension](https://chrome.google.com/webstore/detail/xdebug-helper/eadndfjplgieldjbigjakmdgkmoaaaoc?hl=en)
2. Configure path mapping in PHPStorm (optional, PHPStorm will try to auto-create it during the first debug connect):
    1. Navigate to Settings > PHP > Servers
    2. Click add (plus icon)
    3. Fill in the following details:
        - name: _
        - host: _
        - port: 80
        - Debugger: XDebug
        - Use path mappings: tick this
        - map project root folder to /app (Set the "Absolute path on the server" to "/app")
    4. save

Steps to enable debug session:
1. Click the "Debug" button in the xdebug helper extension in your browser.
2. Click "Start Listening for PHP debug connections" button in PHP Storm.
3. Reload the page in your browser then you should get a popup in PHP Storm about the incoming debug request.

Steps to disable debug session:
1. Click the "Disable" button in the xdebug helper extension in your browser.
2. Click the "Stop Listening for PHP debug connections" button in PHP Storm.

### Xdebug for CLI

The docker environment comes with 2 console containers (console and console-debug).
The default one does not have xdebug installed to be as fast as possible while the debug one has all the necessary configurations for xdebug.
So to debug CLI you just need to exec to the console-debug container rather than the console container.

Steps to enable debug session:
1. Open a bash in the debug console container: `docker-compose exec --user=appuser console-debug bash`
2. Click "Start Listening for PHP debug connections" button in PHP Storm.
3. Run bin/magento then you should get a popup in PHP Storm about the incoming debug request.

Steps to disable debug session:
1. Exit the debug console container and go back to use the normal console container
2. Click the "Stop Listening for PHP debug connections" button in PHP Storm.

## How to configure SSL certificate

Normally the browser will identify your dev env as "Not Secure" due to the self-signed certificate.
You can get around this issue using [mkcert](https://github.com/FiloSottile/mkcert) which can generate locally trusted development certificates.
To install mkcert please refer to the documentation [here](https://github.com/FiloSottile/mkcert#installation);

Once you have mkcert installed, you can generate the SSL certification for your development environment like this:
```bash
mkdir -p certs && cd $_
mkcert -install
mkcert -key-file nginx.key -cert-file nginx.crt docker-test-project.local *.docker-test-project.local
cd -
```
Then you need configure nginx to serve this certification rather than the one provided by the container.
You can do this in the following way:

1. Create a `docker-compose.override.yml` file in the project root
2. Add the following content to this yml file:
```yml
version: '3.7'

services:
  nginx-tls-offload:
    volumes:
      - ./certs:/etc/nginx/certs
```
3. Run `docker-compose stop nginx-tls-offload && docker-compose up -d`

Restart your browser then visit [https://docker-test-project.local](https://docker-test-project.local) and now it should have a valid, trusted certificate.
