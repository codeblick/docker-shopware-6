ARG PHP_VERSION=8.3
FROM php:${PHP_VERSION}-apache AS builder

RUN apt-get update && \
    apt-get install -y \
    build-essential \
    pkg-config \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libxml2-dev \
    libonig-dev \
    libzip-dev \
    libicu-dev \
    libxslt1-dev \
    libssl-dev \
    g++ \
    wget \
    jq \
    git \
    redis-tools

RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-configure intl
RUN docker-php-ext-install \
    pdo \
    pdo_mysql \
    iconv \
    mbstring \
    soap \
    xsl \
    xml \
    gd \
    intl \
    ftp

RUN pecl install apcu && docker-php-ext-enable apcu
RUN pecl install excimer && docker-php-ext-enable excimer
RUN pecl install zstd && docker-php-ext-enable zstd

RUN mkdir -p /usr/src/php/ext/redis && \
    curl -fsSL https://pecl.php.net/get/redis --ipv4 | tar xvz -C "/usr/src/php/ext/redis" --strip 1 && \
    docker-php-ext-install redis

ARG WITH_XDEBUG
RUN if [ "$WITH_XDEBUG" = "1" ] ; then pecl install xdebug && docker-php-ext-enable xdebug; fi

ENV NVM_DIR /usr/local/nvm
RUN mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.39.7/install.sh | bash && \
    export NVM_DIR="/usr/local/nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
    nvm install 20.12.0 && \
    node --version

RUN curl -s -o /usr/local/bin/composer https://getcomposer.org/download/2.5.8/composer.phar && \
    chmod +x /usr/local/bin/composer


FROM php:${PHP_VERSION}-apache

COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/
COPY --from=builder /usr/local/bin/composer /usr/local/bin/composer

COPY --from=builder /usr/local/nvm/ /usr/local/nvm/
ENV NVM_DIR /usr/local/nvm
ENV PATH $NVM_DIR/versions/node/v20.12.0/bin:$PATH

ENV PHP_MAX_EXECUTION_TIME=30
ENV PHP_MEMORY_LIMIT=512M
ENV UPLOAD_MAX_FILE_SIZE=50M
ENV POST_MAX_FILE_SIZE=50M
ENV OPCACHE_ENABLE=1
ENV OPCACHE_MAX_ACCELERATED_FILES=20000
ENV OPCACHE_MEMORY_CONSUMPTION=256M
ENV OPCACHE_REVALIDATE_FREQ=0
ENV APCU_ENABLED=1
ENV APCU_SHM_SIZE=128M
ENV APCU_ENABLE_CLI=1
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

RUN a2enmod rewrite headers expires
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN chown www-data:www-data /var/www && \
    usermod --non-unique --uid 1000 www-data && \
    groupmod --non-unique --gid 1000 www-data

USER www-data