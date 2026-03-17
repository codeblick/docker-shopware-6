# Shopware 6 Docker Image

Docker-Image für Shopware 6 Entwicklungsumgebungen bei Codeblick. Basierend auf `php:*-apache` (Debian Bookworm).

## Tags

- `codeblick/shopware-6:php-8.2`
- `codeblick/shopware-6:php-8.2-xdebug`
- `codeblick/shopware-6:php-8.3`
- `codeblick/shopware-6:php-8.3-xdebug`
- `codeblick/shopware-6:php-8.4`
- `codeblick/shopware-6:php-8.4-xdebug`
- `codeblick/shopware-6:php-8.5`
- `codeblick/shopware-6:php-8.5-xdebug`

Tags mit `-xdebug`-Suffix enthalten eine vollständig aktivierte Xdebug-Installation (Build-Arg `WITH_XDEBUG=1`).

## Features

- **Apache** mit aktivierten Modulen: `rewrite`, `headers`, `expires`
- **Composer** 2.5.8
- **Node.js** via NVM (Version konfigurierbar über Build-Arg `NODE_VERSION`)
- **PHP-Extensions:** gd, iconv, pdo, pdo_mysql, mbstring, xml, zip, intl, opcache, soap, xsl, ftp, apcu, excimer, zstd, amqp, redis
- **MSSQL-Unterstützung:** sqlsrv, pdo_sqlsrv (msodbcsql18, mssql-tools18) ab PHP 8.3
- **Xdebug** (optional, siehe Build-Args)
- **Tools:** git, jq, wget, redis-tools
- Läuft als `www-data` (UID/GID 1000)
- Zeitzone: `Europe/Berlin`

## Build-Args

| Argument       | Beschreibung                                |
| -------------- | ------------------------------------------- |
| `PHP_VERSION`  | PHP-Version (z. B. `8.3`, `8.4`)            |
| `NODE_VERSION` | Node.js-Version (z. B. `20`, `22`)          |
| `WITH_XDEBUG`  | Xdebug installieren (`1` = ja, leer = nein) |

### Beispiel

```bash
docker build \
  --build-arg PHP_VERSION=8.3 \
  --build-arg NODE_VERSION=20 \
  --build-arg WITH_XDEBUG=1 \
  -t codeblick/shopware-6:php-8.3-xdebug .
```

## Umgebungsvariablen

Alle Werte können zur Laufzeit überschrieben werden.

### PHP

| Variable                 | Default |
| ------------------------ | ------- |
| `PHP_MAX_EXECUTION_TIME` | `30`    |
| `PHP_MEMORY_LIMIT`       | `512M`  |
| `UPLOAD_MAX_FILE_SIZE`   | `50M`   |
| `POST_MAX_FILE_SIZE`     | `50M`   |

### OPcache

| Variable                        | Default |
| ------------------------------- | ------- |
| `OPCACHE_ENABLE`                | `1`     |
| `OPCACHE_MAX_ACCELERATED_FILES` | `20000` |
| `OPCACHE_MEMORY_CONSUMPTION`    | `256M`  |
| `OPCACHE_REVALIDATE_FREQ`       | `0`     |

### APCu

| Variable          | Default |
| ----------------- | ------- |
| `APCU_ENABLED`    | `1`     |
| `APCU_SHM_SIZE`   | `128M`  |
| `APCU_ENABLE_CLI` | `1`     |

### Xdebug

| Variable                        | Default       |
| ------------------------------- | ------------- |
| `PHP_XDEBUG_MODE`               | `profile`     |
| `PHP_XDEBUG_START_WITH_REQUEST` | `trigger`     |
| `PHP_XDEBUG_HOST`               | `docker.host` |
| `PHP_XDEBUG_PORT`               | `9000`        |
| `PHP_XDEBUG_IDEKEY`             | `VSCODE`      |
| `PHP_XDEBUG_MAX_NESTING_LEVEL`  | `256`         |

### Sonstiges

| Variable                          | Default                |
| --------------------------------- | ---------------------- |
| `APACHE_DOCUMENT_ROOT`            | `/var/www/html/public` |
| `COMPOSER_PROCESS_TIMEOUT`        | `900`                  |
| `PHP_ZEND_MAX_ALLOWED_STACK_SIZE` | `0`                    |

## Verwendung mit Docker Compose

```yaml
services:
  shopware:
    image: codeblick/shopware-6:php-8.3-xdebug
    ports:
      - "80:80"
    volumes:
      - .:/var/www/html
    environment:
      PHP_MEMORY_LIMIT: 1G
      PHP_XDEBUG_MODE: debug
```
