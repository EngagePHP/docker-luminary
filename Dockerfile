FROM mcuyar/docker-alpine-nginx-php7:latest
MAINTAINER Matthew Cuyar <matt@enctypeapparel.com>

##/
 # Install Luminary
 #/
RUN cd /var \
    && rm -rf www \
    && composer create-project --prefer-dist --stability dev --no-dev engage-php/luminary www \
    && composer clearcache \
    && rm -rf www/composer.lock

##/
 # Copy files
 #/
COPY rootfs /

EXPOSE 8000