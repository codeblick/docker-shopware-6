ARG PHP_VERSION

FROM php:${PHP_VERSION}-apache

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

ENV PHP_XDEBUG_MODE=profile
ENV PHP_XDEBUG_START_WITH_REQUEST=trigger

ENV PHP_XDEBUG_HOST=docker.host
ENV PHP_XDEBUG_PORT=9000
ENV PHP_XDEBUG_IDEKEY=VSCODE

ENV COMPOSER_PROCESS_TIMEOUT=900

ENV PHP_ZEND_MAX_ALLOWED_STACK_SIZE=1024
ENV PHP_XDEBUG_MAX_NESTING_LEVEL=1024

RUN apt-get update
RUN apt-get install -y \
    # ext-gd
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    # ext-curl
    curl \
    libcurl4-gnutls-dev \
    # ext-xml
    libxml2-dev \
    # ext-mbstring
    libonig-dev \
    # ext-zip
    zip \
    libzip-dev \
    # intl
    zlib1g-dev \
    libicu-dev \
    # xsl
    libxslt1-dev \
    g++ \
    wget \
    jq \
    git
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-configure intl
RUN docker-php-ext-install \
    gd \
    iconv \
    pdo \
    pdo_mysql \
    mbstring \
    xml \
    zip \
    intl \
    opcache \
    soap \
    xsl

RUN pecl install apcu; \
    docker-php-ext-enable apcu; \
    pecl install excimer; \
    docker-php-ext-enable excimer

RUN mkdir -p /usr/src/php/ext/redis; \
    curl -fsSL https://pecl.php.net/get/redis --ipv4 | tar xvz -C "/usr/src/php/ext/redis" --strip 1; \
    docker-php-ext-install redis

ARG WITH_XDEBUG
RUN if [ "$WITH_XDEBUG" = "1" ] ; then pecl install xdebug && docker-php-ext-enable xdebug; fi

ADD etc/php-config.ini /usr/local/etc/php/conf.d/php-config.ini

RUN a2enmod rewrite
RUN a2enmod headers
RUN a2enmod expires
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

ENV NVM_DIR /usr/local/nvm
RUN mkdir -p $NVM_DIR

ARG NODE_VERSION
RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.39.7/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION

ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN curl -s -o /usr/local/bin/composer https://getcomposer.org/download/2.5.8/composer.phar && \
    chmod +x /usr/local/bin/composer

RUN chown www-data:www-data /var/www; \
    usermod --non-unique --uid 1000 www-data; \
    groupmod --non-unique --gid 1000 www-data

USER www-data
