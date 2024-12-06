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
    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/ \
    # https://pecl.php.net/package/imagick
    # https://github.com/Imagick/imagick/commit/5ae2ecf20a1157073bad0170106ad0cf74e01cb6 (causes a lot of build failures, but strangely only intermittent ones 🤔)
    # see also https://github.com/Imagick/imagick/pull/641
    # this is "pecl install imagick-3.7.0", but by hand so we can apply a small hack / part of the above commit
    curl -fL -o imagick.tgz 'https://pecl.php.net/get/imagick-3.7.0.tgz'; \
    echo '5a364354109029d224bcbb2e82e15b248be9b641227f45e63425c06531792d3e *imagick.tgz' | sha256sum -c -; \
    tar --extract --directory /tmp --file imagick.tgz imagick-3.7.0; \
    grep '^//#endif$' /tmp/imagick-3.7.0/Imagick.stub.php; \
    test "$(grep -c '^//#endif$' /tmp/imagick-3.7.0/Imagick.stub.php)" = '1'; \
    sed -i -e 's!^//#endif$!#endif!' /tmp/imagick-3.7.0/Imagick.stub.php; \
    grep '^//#endif$' /tmp/imagick-3.7.0/Imagick.stub.php && exit 1 || :; \
    docker-php-ext-install /tmp/imagick-3.7.0; \
    rm -rf imagick.tgz /tmp/imagick-3.7.0; \
#构建
#docker build -f php8.3-work.Dockerfile -t php:8.3.14-fpm-v1.0 .