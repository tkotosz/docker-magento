ARG XDEBUG=0
FROM php:7.4-cli AS base

# Install php extension installer tool
# See https://github.com/mlocati/docker-php-extension-installer
COPY --from=mlocati/php-extension-installer:latest /usr/bin/install-php-extensions /usr/local/bin/

# Install debian package installer script
# See https://github.com/tkotosz/debian-package-clean-install
COPY --from=tkotosz/debian-package-clean-install /usr/bin/debian-package-clean-install /usr/local/bin/

# Install create-user script
# See https://github.com/tkotosz/create-user
COPY --from=tkotosz/create-user /usr/bin/create-user /usr/local/bin/

# Install & configure mhsendmail
# See https://github.com/tkotosz/docker-mhsendmail
# See https://github.com/tkotosz/mhsendmail-wrapper
COPY --from=tkotosz/mhsendmail:0.2.0 /usr/bin/mhsendmail /usr/local/bin/mhsendmail
COPY --from=tkotosz/mhsendmail-wrapper:latest /usr/bin/mhsendmail-wrapper /usr/local/bin/send_mail
RUN echo 'sendmail_path = "/usr/local/bin/send_mail"' > /usr/local/etc/php/conf.d/send_mail.ini

# Install resolve-docker-host-ip script
# See https://github.com/tkotosz/resolve-docker-host-ip
RUN debian-package-clean-install iproute2
COPY --from=tkotosz/resolve-docker-host-ip /usr/bin/resolve-docker-host-ip /usr/local/bin/resolve-docker-host-ip

# Create app user
ARG APP_USER=appuser
ARG APP_GROUP=appuser
ARG APP_USER_ID=1000
ARG APP_GROUP_ID=1000
RUN create-user ${APP_USER} ${APP_GROUP} ${APP_USER_ID} ${APP_GROUP_ID}

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

# Install additional tools
RUN debian-package-clean-install \
    # required to connect to mysql cli from the console container
    default-mysql-client \
    # required for patch applies
    patch \
    git \
    # required for prefer-source composer install
    ssh-client

# Install composer
COPY --from=composer:2.0 /usr/bin/composer /usr/bin/composer

# Install n98 magerun
RUN curl -O https://files.magerun.net/n98-magerun2.phar \
  && chmod +x ./n98-magerun2.phar \
  && mv ./n98-magerun2.phar /usr/local/bin/n98-magerun2

# Add configurations
COPY root /

## Image without xdebug
FROM base AS base-0

## Image with xdebug
FROM base AS base-1

# Install & configure xdebug
RUN install-php-extensions xdebug
RUN echo "zend_extension=xdebug" > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && echo "xdebug.client_port=9000" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
ENV PHP_IDE_CONFIG="serverName=_"

## Final image (choose default or xdebug version)
FROM base-${XDEBUG} AS final

WORKDIR /app

ENTRYPOINT ["/usr/local/bin/resolve-docker-host-ip","sleep","infinity"]
