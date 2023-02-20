# Shopware 6 docker image

## Tags

- codeblick/shopware-6:php-8.0
- codeblick/shopware-6:php-8.0-xdebug
- codeblick/shopware-6:php-8.1
- codeblick/shopware-6:php-8.1-xdebug
- codeblick/shopware-6:php-8.2
- codeblick/shopware-6:php-8.2-xdebug

# Environment variables (default)

```
PHP_MAX_EXECUTION_TIME=30
PHP_MEMORY_LIMIT=512M

UPLOAD_MAX_FILE_SIZE=50M
POST_MAX_FILE_SIZE=50M

OPCACHE_ENABLE=1
OPCACHE_MAX_ACCELERATED_FILES=20000
OPCACHE_MEMORY_CONSUMPTION=256M
OPCACHE_REVALIDATE_FREQ=0

APCU_ENABLED=1
APCU_SHM_SIZE=128M
APCU_ENABLE_CLI=1

APACHE_DOCUMENT_ROOT /var/www/html/public

PHP_XDEBUG=0
PHP_XDEBUG_HOST=docker.host
PHP_XDEBUG_IDEKEY=VSCODE
PHP_XDEBUG_PORT=9000
```
