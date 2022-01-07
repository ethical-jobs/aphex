ARG PHP_VERSION=7.3
FROM php:$PHP_VERSION-fpm-alpine3.10 AS php

LABEL maintainer="Ethical Jobs <development@ethicaljobs.com.au>"

FROM php AS php_modules

RUN apk --no-cache add \
        freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev \
        oniguruma-dev \
        wget \
        git \
        supervisor \
        bash \
    && NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
    && docker-php-ext-configure gd \
    && pecl install xdebug && pecl clear-cache \
    && docker-php-ext-install -j${NPROC} \
        mysqli \
        pdo_mysql \
        opcache \
        pcntl \
        bcmath \
        exif \
        mbstring \
        gd \
    && docker-php-source delete

FROM php AS composer

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
    && composer global clear-cache

FROM php_modules AS aphex

COPY --from=composer /usr/bin/composer /usr/bin/composer
COPY --from=composer /root/.composer /root/.composer

RUN mkdir -p /var/log/cron \
    && mkdir -p /var/www \
    && mkdir -p /var/entrypoints \
    && touch /var/log/cron/cron.log \
    && mkdir -m 0644 -p /etc/cron.d \
    && chmod -R 0644 /etc/cron.d

COPY ./bin/* /root/aphex/bin/

RUN chmod +x /root/aphex/bin/*

# Copy crontab, supervisord configuration and entrypoints to image
COPY ./config/bin/schedule /etc/crontabs/root
COPY ./config/supervisord.conf /etc/supervisord.conf
COPY ./config/entrypoints/* /var/entrypoints/

ENV TZ="Australia/Melbourne"
ENV PATH="$PATH:/var/www/vendor/bin"

WORKDIR /var/www

RUN touch /var/log/cron/cron.log

ENV SCHEDULE_LOG_PATH /var/log/cron/cron.log

FROM aphex AS nginx

RUN apk --no-cache add nginx~1.16

#
#--------------------------------------------------------------------------
# Init
#--------------------------------------------------------------------------
#

EXPOSE 80 443

ENTRYPOINT ["/var/entrypoints/laravel"]

CMD ["/usr/bin/supervisord", "-n"]
