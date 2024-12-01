FROM composer:2.8.3 as composer

FROM php:8.3.14-fpm
COPY --from=composer /usr/bin/composer /usr/bin/composer

RUN apt-get update && apt-get install -y vim git procps inetutils-ping net-tools unzip \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libzip-dev \
        libicu-dev \
        libpq-dev \
        libmagickwand-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && pecl install redis-6.1.0 mongodb-1.20.1 xdebug-3.4.0 apcu-5.1.24 \
    && docker-php-ext-enable redis mongodb xdebug apcu \
    && docker-php-ext-install pdo pdo_mysql mysqli zip sockets bcmath pdo_pgsql pgsql intl pcntl \
    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

#构建
#docker build -f php8.3-work.Dockerfile -t php:8.3.14-fpm-v1.0 .