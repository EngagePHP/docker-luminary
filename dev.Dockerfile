FROM mcuyar/docker-luminary:latest
MAINTAINER Matthew Cuyar <matt@enctypeapparel.com>

##/
 # Install Lumen CLI
 #/
RUN cd /var/www \
    && composer install \
    && composer clearcache \
    && rm -rf www/composer.lock

##/
 # Copy files
 #/
COPY rootfs /