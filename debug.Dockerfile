#----------------------------------------------------
# Base Alpine image
#----------------------------------------------------
FROM alpine:3.9 as base
MAINTAINER Matthew Cuyar <matt@elumatherapy.com>

# Config Alpine
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

RUN apk --no-cache add tzdata && \
    cp /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    echo "UTC" | tee /etc/timezone && \
    apk del tzdata

# Base packages for Alpine
RUN apk add --no-cache bash git

# Add s6 Overlay
# @credit John Regan <john@jrjrtech.com>
# @original https://github.com/just-containers/s6-overlay

ARG s6_version=v1.22.0.0
RUN apk add --no-cache wget \
 && wget https://github.com/just-containers/s6-overlay/releases/download/${s6_version}/s6-overlay-amd64.tar.gz --no-check-certificate -O /tmp/s6-overlay.tar.gz \
 && tar xvfz /tmp/s6-overlay.tar.gz -C / \
 && rm -f /tmp/s6-overlay.tar.gz \
 && apk del wget

# Add PHP 7
RUN apk --no-cache add \
    php7 php7-cgi php7-ctype php7-curl php7-dom php7-exif php7-fileinfo php7-fpm php7-ftp php7-gd php7-iconv \
    php7-intl php7-json php7-ldap php7-mbstring php7-mcrypt php7-mysqli php7-opcache php7-openssl php7-pcntl \
    php7-pdo_mysql php7-pdo_pgsql php7-phar php7-pgsql php7-posix php7-redis php7-session php7-simplexml \
    php7-sockets php7-tokenizer php7-xml php7-xmlreader php7-xmlwriter php7-zip php7-zlib

# Add composer
ENV COMPOSER_HOME=/composer
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PATH $COMPOSER_HOME/vendor/bin:$PATH

RUN apk --no-cache add curl \
    && mkdir /composer \
    && curl -sS https://getcomposer.org/installer | php \
    && mkdir -p /opt/composer \
    && mv composer.phar /opt/composer/composer.phar \
    && apk del curl

# Set FPM Log output to stderr
RUN mkdir -p /var/log/php7 \
 && touch /var/log/php7/fpm-error.log \
 && ln -sf /dev/stderr /var/log/php7/fpm-error.log

# Add NGINX
RUN apk --no-cache add nginx
# Clean default Nginx site folder
RUN rm -rf /var/www/*
# Set the access and error logs to go to stdout/stderr
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# Add the root file system
COPY rootfs /

# Add Codeship Jet
RUN apk --no-cache add --virtual .build-deps bash curl tar libxml2-utils \
    && export JET_VERSION=$(/opt/scripts/jet-latest.sh) \
    && curl -SLO "https://s3.amazonaws.com/codeship-jet-releases/${JET_VERSION}/jet-linux_amd64_${JET_VERSION}.tar.gz" \
    && tar -xaC /usr/local/bin -f jet-linux_amd64_${JET_VERSION}.tar.gz \
    && chmod +x /usr/local/bin/jet \
    && apk del .build-deps \
    && rm -f jet-linux_amd64_${JET_VERSION}.tar.gz

# Set the work directory
WORKDIR /var/www

# Expose ports
EXPOSE 8000

# Set the entrypoint
ENTRYPOINT [ "/init" ]

#----------------------------------------------------
# @target: Dev Build
#----------------------------------------------------
# Install the project
RUN composer create-project --prefer-dist --stability dev engage-php/luminary . \
    && composer clearcache \
    && rm -rf composer.lock

# Set the permissions
RUN chown -R nginx:nginx /var/www
RUN find /var/www -type f -exec chmod 644 {} \;
RUN find /var/www -type d -exec chmod 755 {} \;

# Add Xdebug
RUN apk --no-cache add php7-xdebug
COPY dev-rootfs /
