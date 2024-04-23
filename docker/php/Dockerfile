FROM php:8.2-fpm

RUN apt-get update && apt-get install -y cron git-core jq unzip vim zip \
  libjpeg-dev libpng-dev libpq-dev libsqlite3-dev libwebp-dev libzip-dev && \
  rm -rf /var/lib/apt/lists/* && \
  docker-php-ext-configure zip --with-zip && \
  docker-php-ext-configure gd --with-jpeg --with-webp && \
  docker-php-ext-install exif gd mysqli opcache pdo_pgsql pdo_mysql zip pgsql

# RUN { \
#    echo 'opcache.memory_consumption=128'; \
#    echo 'opcache.interned_strings_buffer=8'; \
#    echo 'opcache.max_accelerated_files=4000'; \
#    echo 'opcache.revalidate_freq=2'; \
#    echo 'opcache.fast_shutdown=1'; \
#    echo 'opcache.enable_cli=1'; \
#  } > /usr/local/etc/php/conf.d/docker-oc-opcache.ini

RUN { \
    echo 'log_errors=on'; \
    echo 'display_errors=off'; \
    echo 'upload_max_filesize=10000M'; \
    echo 'post_max_size=512M'; \
    echo 'memory_limit=512M'; \
  } > /usr/local/etc/php/conf.d/docker-oc-php.ini

ENV COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_MEMORY_LIMIT=-1

RUN curl -sS https://getcomposer.org/installer | php -- --2 --install-dir=/usr/local/bin --filename=composer && \
  chown -R www-data:www-data /var/www

# Change current user to www-data
USER www-data

CMD ["php-fpm"]
