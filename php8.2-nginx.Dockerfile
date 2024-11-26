FROM php:8.2.17-fpm
RUN apt-get update && apt-get install -y git procps inetutils-ping net-tools nginx \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libzip-dev \
        libssl-dev \
        libcurl4-openssl-dev \
        libc-ares-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && pecl install redis-5.3.7 mongodb-1.14.0 \
    && pecl install -D 'enable-sockets="no" enable-openssl="yes" enable-http2="yes" enable-mysqlnd="yes" enable-swoole-json="no" enable-swoole-curl="yes" enable-cares="yes"' swoole-5.1.5 \
    && docker-php-ext-install pdo pdo_mysql mysqli zip sockets \
    && docker-php-ext-enable redis swoole mongodb \
    && curl -sfL https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
    && chmod +x /usr/bin/composer \
    && composer self-update 2.3.10 \
    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/ \
    && mkdir -p /var/log/php \
    && mkdir -p /var/log/php-fpm

EXPOSE 80
COPY ./php8.2-nginx/code /app

COPY ./php8.2-nginx/php/php/php.ini /usr/local/etc/php/php.ini
COPY ./php8.2-nginx/php/php-fpm.d/docker.conf /usr/local/etc/php-fpm.d/docker.conf
COPY ./php8.2-nginx/php/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf

COPY ./php8.2-nginx/nginx/nginx.conf /etc/nginx/nginx.conf

CMD nginx && php-fpm