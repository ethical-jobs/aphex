FROM ethicaljobs/aphex:latest

ADD ./example/nginx.conf /etc/nginx/nginx.conf

RUN mkdir /build
WORKDIR /var/www

RUN rm -rf /var/www/html
RUN composer create-project --prefer-dist laravel/laravel .
