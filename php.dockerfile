FROM php:7.4.30-fpm-alpine

ENV PHPUSER=appuser
ENV PHPGROUP=appuser

RUN apk update && apk add --no-cache \
    freetype \
    libjpeg-turbo \
    libpng \
    libzip \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libzip-dev \
    libwebp-dev \
    linux-headers \
    $PHPIZE_DEPS

RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
    --with-webp

RUN docker-php-ext-install -j$(nproc) gd pdo pdo_mysql mysqli zip

RUN adduser -g ${PHPGROUP} -s /bin/sh -D ${PHPUSER}

RUN sed -i "s/user = www-data/user = ${PHPUSER}/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/group = www-data/group = ${PHPGROUP}/g" /usr/local/etc/php-fpm.d/www.conf

RUN mkdir -p /var/www/html

CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]