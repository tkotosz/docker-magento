# docker-magento

DEV env for Magento 2.4.7

## Setup the project

```sh
git clone git@github.com:tkotosz/docker-magento.git
cd docker-magento
./setup-dev-env.sh
```

Docker images built from: https://github.com/tkotosz/docker-magento/tree/2.4.7-develop

## Optional steps

### Mount your ssh keys (for e.g. to install private packages):

Update `docker-compose.override.yml` with this (create the file if doesn't exist):
```yml
services:
  console:
    volumes:
      - ~/.ssh:/home/appuser/.ssh

  console-debug:
    volumes:
      - ~/.ssh:/home/appuser/.ssh
```
Then you can run `docker-compose up -d` to apply the changes.

### Generate valid ssl cert

Normally the browser will identify your dev env as "Not Secure" due to invalid ssl certificate.
You can get around this issue using [mkcert](https://github.com/FiloSottile/mkcert) which can generate locally trusted development certificates.
To install mkcert please refer to the documentation [here](https://github.com/FiloSottile/mkcert#installation);

Once you have mkcert installed, you can generate the SSL certification for your development environment like this:
```bash
mkdir -p certs && cd $_
mkcert -install
mkcert -key-file nginx.key -cert-file nginx.crt docker-test-project.local *.docker-test-project.local
```

Update `docker-compose.override.yml` with this (create the file if doesn't exist) to mount the cert:
```yml
services:
  nginx-proxy:
    volumes:
      - ./certs:/etc/nginx/certs
```
Then you can run `docker-compose up -d` to apply the changes (browser restart might be required as well).
