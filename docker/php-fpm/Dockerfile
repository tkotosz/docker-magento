ARG XDEBUG=0

###########################################
## Prepare base php-fpm image for magento:
## - install required php extensions
###########################################
FROM php:7.4-fpm-alpine AS php7.4-fpm-alpine-magento

# Install php extension installer tool
# See https://github.com/mlocati/docker-php-extension-installer
COPY --from=mlocati/php-extension-installer:latest /usr/bin/install-php-extensions /usr/local/bin/

# Install required PHP extensions
# See https://devdocs.magento.com/guides/v2.4/install-gde/prereq/php-settings.html#verify-installed-extensions
RUN install-php-extensions \
  bcmath \
  ctype \
  curl \
  dom \
  gd \
  hash \
  iconv \
  intl \
  mbstring \
  openssl \
  pdo_mysql \
  simplexml \
  soap \
  xsl \
  zip \
  sockets

# Install additional PHP extensions
RUN install-php-extensions \
  opcache \
  pcntl \
  redis \
  imagick


#######################################
## Extend base php-fpm magento image:
## - install sendmail
## - override www-data user id
#######################################
FROM php7.4-fpm-alpine-magento AS php7.4-fpm-alpine-magento-dev

# Install & configure mhsendmail
# See https://github.com/tkotosz/docker-mhsendmail
# See https://github.com/tkotosz/mhsendmail-wrapper
COPY --from=tkotosz/mhsendmail:0.2.0 /usr/bin/mhsendmail /usr/local/bin/mhsendmail
COPY --from=tkotosz/mhsendmail-wrapper:latest /usr/bin/mhsendmail-wrapper /usr/local/bin/send_mail
RUN echo 'sendmail_path = "/usr/local/bin/send_mail"' > /usr/local/etc/php/conf.d/send_mail.ini

# Create app user
ARG APP_USER_ID=1000
ARG APP_GROUP_ID=1000
RUN addgroup -g ${APP_GROUP_ID} appuser \
    && adduser -u ${APP_USER_ID} -G appuser -h /home/appuser -s /bin/sh -D appuser

# Add configurations
COPY root /


##################################
## DEV env image without xdebug
##################################
FROM php7.4-fpm-alpine-magento-dev AS php7.4-fpm-alpine-magento-dev-0


##############################
## DEV env image with xdebug
##############################
FROM php7.4-fpm-alpine-magento-dev AS php7.4-fpm-alpine-magento-dev-1

# Install and configure xdebug
RUN install-php-extensions xdebug
RUN echo "zend_extension=xdebug" > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && echo "xdebug.client_port=9000" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Install resolve-docker-host-ip script
# See https://github.com/tkotosz/resolve-docker-host-ip
RUN apk add --no-cache iproute2
COPY --from=tkotosz/resolve-docker-host-ip /usr/bin/resolve-docker-host-ip /usr/local/bin/resolve-docker-host-ip

ENTRYPOINT ["/usr/local/bin/resolve-docker-host-ip","php-fpm"]


###################################################
## Final DEV env image:
## - with or without xdebug based on ${XDEBUG} arg
###################################################
FROM php7.4-fpm-alpine-magento-dev-${XDEBUG} AS php7.4-fpm-alpine-magento-dev-final

WORKDIR /app

EXPOSE 9000
