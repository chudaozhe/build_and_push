FROM php:7.4-fpm
ADD docker-php-ext-swoole-loader.ini /usr/local/etc/php/conf.d/
ADD swoole_loader74.so /usr/local/lib/php/extensions/no-debug-non-zts-20190902/
RUN apt-get update && apt-get install -y git procps inetutils-ping net-tools unzip supervisor \
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
    && pecl install redis-5.3.7 mongodb-1.14.0 imagick-3.7.0 memcache-4.0.5.2 apcu-5.1.22 \
    && pecl install -D 'enable-sockets="no" enable-openssl="yes" enable-http2="yes" enable-mysqlnd="yes" enable-swoole-json="no" enable-swoole-curl="yes" enable-cares="yes"' swoole-4.8.12 \
    && docker-php-ext-enable redis swoole mongodb imagick memcache apcu \
    && docker-php-ext-install pdo pdo_mysql mysqli zip sockets bcmath intl \
    && curl -sfL https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
    && chmod +x /usr/bin/composer \
    && composer self-update 2.3.10 \
    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

EXPOSE 8321 8325

CMD supervisord -c /etc/supervisor/supervisord.conf \
    && php-fpm

#构建
#docker build -f php7.4-swoole-work.Dockerfile -t php:7.4-swoole-fpm-v1.1 .