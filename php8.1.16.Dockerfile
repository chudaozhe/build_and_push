FROM php:8.1.16-fpm
RUN apt-get update && apt-get install -y git procps inetutils-ping net-tools \
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
    && pecl install -D 'enable-sockets="no" enable-openssl="yes" enable-http2="yes" enable-mysqlnd="yes" enable-swoole-json="no" enable-swoole-curl="yes" enable-cares="yes"' swoole-5.0.0 \
    && docker-php-ext-install pdo pdo_mysql mysqli zip sockets \
    && docker-php-ext-enable redis swoole mongodb \
    && curl -sfL https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
    && chmod +x /usr/bin/composer \
    && composer self-update 2.3.10 \
    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

