FROM varnish:7.0

# Install debian package installer script
# See https://github.com/tkotosz/debian-package-clean-install
COPY --from=tkotosz/debian-package-clean-install /usr/bin/debian-package-clean-install /usr/local/bin/

# Install envsubst (part of gettext-base)
RUN debian-package-clean-install gettext-base

# Configure default backend host & port
ENV BACKEND_HOST=nginx
ENV BACKEND_PORT=80

# Add varnish config template
COPY root /

ENTRYPOINT ["/usr/local/bin/varnish-envsubst","/usr/local/bin/docker-varnish-entrypoint"]

EXPOSE 80
