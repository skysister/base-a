FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:ondrej/php && \
    apt-get install -y \
      curl \
      nginx \
      locales \
      unzip && \
    apt-get install -y \
      php8.3-fpm \
      php8.3-curl \
      php8.3-gd \
      php8.3-imagick \
      php8.3-mbstring \
      php8.3-mysql \
      php8.3-soap \
      php8.3-sqlite3 \
      php8.3-xml \
      php8.3-zip \
      sqlite3 && \
    apt-get clean all

# Generate locales
# RUN locale-gen en_US && \
#     locale-gen en_US.utf8 && \
#     locale-gen es_US && \
#     locale-gen es_US.utf8 && \
#     locale-gen es_MX && \
#     locale-gen es_MX.utf8 && \
#     locale-gen es_ES && \
#     locale-gen es_ES.utf8 && \
#     locale-gen ja_JP && \
#     locale-gen ja_JP.utf8 && \
#     update-locale

# Add Nginx user with no shell access
RUN useradd -s /bin/false nginx

RUN mkdir /usr/local/bin/config && \
    mkdir /usr/local/bin/init && \
    mkdir /run/php && chown root:nginx /run/php && \
    mkdir /var/log/php && chmod -R 755 /var/log/php && chown -R root:nginx /var/log/php && \
    mkdir -p /var/www/cache && chmod 755 /var/www/cache && \
    chmod -R 775 /var/lib/php && \
    chown -R root:nginx /var/lib/php && \
    chown -R root:nginx /var/www/html

COPY /files/scripts/config/* /usr/local/bin/config/
COPY /files/scripts/init/* /usr/local/bin/init/
COPY /files/scripts/*.sh /usr/local/bin/

COPY /files/nginx.conf /etc/nginx/
COPY /files/nginx-cache.conf /etc/nginx/conf.d/
COPY /files/default /etc/nginx/sites-available/

RUN chmod -R 755 /usr/local/bin/*

RUN ln -sf /var/www/html /var/www/website && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    ln -sf /var/log/nginx/error.log /var/log/php/fpm-error.log && \
    mkdir /var/log/httpd && touch /var/log/httpd/error_log
    # ln -sf /var/log/php/fpm-error.log /var/log/httpd/error_log

EXPOSE 80 8080

ENTRYPOINT ["docker-entry.sh"]
