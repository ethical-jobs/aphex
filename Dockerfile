FROM php:7.0.11-fpm-alpine

MAINTAINER "Andrew McLagan" <andrew@ethicaljobs.com.au>

#
#--------------------------------------------------------------------------
# Install
#--------------------------------------------------------------------------
#

RUN apk --no-cache add \
        libmcrypt-dev \
        freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev \
        wget \
        git \
        nginx \
        ca-certificates \
        supervisor \
        bash \
    && docker-php-ext-install \
        mcrypt \
        mysqli \
        pdo_mysql \
        opcache \
    && docker-php-ext-configure gd \
        --with-gd \
        --with-freetype-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
    && NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
    && docker-php-ext-install -j${NPROC} gd \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && chown -R www-data:www-data /var/lib/nginx \
    && chown -R www-data:www-data /var/www \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
    && composer global require "hirak/prestissimo:^0.3" 

#
#--------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------
#

ADD ./config/supervisord.conf /etc/supervisord.conf

ADD ./config/nginx.conf /etc/nginx/nginx.conf

ADD ./config/php-fpm.ini /etc/php7/conf.d/php-fpm.ini

#
#--------------------------------------------------------------------------
# Application
#--------------------------------------------------------------------------
#

RUN mkdir -p /var/www

WORKDIR /var/www

ADD ./index.php /var/www/public/index.php

#
#--------------------------------------------------------------------------
# Init
#--------------------------------------------------------------------------
#

EXPOSE 80 443

CMD /usr/bin/supervisord
