FROM surnet/alpine-wkhtmltopdf:3.16.2-0.12.6-full as wkhtmltopdf
FROM php:7.4.30-fpm-alpine as ian_php

ENV PHPUSER=appuser
ENV PHPGROUP=appuser

RUN apk update && apk add --no-cache \
    icu-dev \
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
    $PHPIZE_DEPS \
    # Add these for gRPC
    autoconf \
    g++ \
    make \
    zlib-dev \
    libstdc++ \
    libx11 \
    libxrender \
    libxext \
    libssl3 \
    ca-certificates \
    fontconfig \
    ttf-droid \
    ttf-freefont \
    ttf-liberation;

RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
    --with-webp

RUN docker-php-ext-configure intl

RUN docker-php-ext-install -j$(nproc) gd pdo pdo_mysql mysqli zip intl bcmath

# Install gRPC
RUN pecl install grpc
RUN docker-php-ext-enable grpc

# Copy needed wkhtmltopdf files from wkhtmltopdf image
COPY --from=wkhtmltopdf /bin/wkhtmltoimage /bin/wkhtmltopdf /bin/libwkhtmltox* /bin/

RUN adduser -g ${PHPGROUP} -s /bin/sh -D ${PHPUSER}

RUN sed -i "s/user = www-data/user = ${PHPUSER}/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/group = www-data/group = ${PHPGROUP}/g" /usr/local/etc/php-fpm.d/www.conf

RUN mkdir -p /var/www/html

CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]
