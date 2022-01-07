FROM ethicaljobs/aphex-php7.3:latest

ADD ./example/nginx.conf /etc/nginx/nginx.conf

RUN mkdir /build
WORKDIR /var/www

RUN rm -rf /var/www/html
RUN composer create-project --prefer-dist laravel/laravel .
