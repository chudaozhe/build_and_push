FROM composer:2.8.3 as composer

FROM php:8.2.17-fpm
COPY --from=composer /usr/bin/composer /usr/bin/composer

RUN apt-get update && apt-get install -y git procps inetutils-ping net-tools unzip \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libzip-dev \
        libssl-dev \
        libcurl4-openssl-dev \
        libc-ares-dev \
        libicu-dev \
        libpq-dev \
        libmagickwand-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && pecl install redis-6.1.0 mongodb-1.20.1 xdebug-3.4.0 imagick-3.7.0 apcu-5.1.24 \
    && pecl install -D 'enable-sockets="no" enable-openssl="yes" enable-http2="yes" enable-mysqlnd="yes" enable-swoole-json="no" enable-swoole-curl="yes" enable-cares="yes"' swoole-6.0.2 \
    && docker-php-ext-enable redis swoole mongodb xdebug imagick apcu \
    && docker-php-ext-install pdo pdo_mysql mysqli zip sockets bcmath pdo_pgsql pgsql intl pcntl \
    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

#构建
#docker build -f php8.2-swoole-work.Dockerfile -t php:8.2.17-fpm-swoole-v1.0 .
