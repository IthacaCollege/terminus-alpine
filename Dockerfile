FROM php:7.4-alpine
ENV TERMINUS_DIR=/usr/local/share/terminus \
    TERMINUS_PLUGINS_DIR=/usr/local/share/terminus-plugins \
    TZ=America/New_York
RUN apk add --no-cache --virtual .dd-build-deps libxml2-dev oniguruma-dev $PHPIZE_DEPS \
    && apk add --no-cache --upgrade bash git libzip-dev mysql-client openssh-client patch rsync \
    && docker-php-ext-install bcmath opcache pcntl pdo_mysql soap zip \
    && pecl install redis-3.1.1 \
    && docker-php-ext-enable redis \
    && wget -O /usr/local/bin/composer https://getcomposer.org/composer.phar \
    && chmod +x /usr/local/bin/composer \
    && apk del .dd-build-deps \
    && pecl clear-cache \
    && ( \
        echo 'opcache.memory_consumption=128' \
        && echo 'opcache.interned_strings_buffer=8' \
        && echo 'opcache.max_accelerated_files=4000' \
        && echo 'opcache.revalidate_freq=60' \
        && echo 'opcache.fast_shutdown=1' \
        && echo 'opcache.enable_cli=1' \
    ) >> $PHP_INI_DIR/conf.d/docker-php-ext-opcache.ini

COPY set-environment /usr/local/bin/set-environment
RUN composer -n global require -n "hirak/prestissimo:^0.3" \
    && mkdir -p ${TERMINUS_DIR} \
    && mkdir -p ${TERMINUS_PLUGINS_DIR} 
RUN composer -n --working-dir=${TERMINUS_DIR} require --update-no-dev -o pantheon-systems/terminus:^2.3 \
    && composer -n create-project --no-dev -d ${TERMINUS_PLUGINS_DIR} pantheon-systems/terminus-build-tools-plugin:^2.0.0-beta17 \
    && composer -n create-project --no-dev -d ${TERMINUS_PLUGINS_DIR} pantheon-systems/terminus-secrets-plugin \
    && composer -n create-project --no-dev -d ${TERMINUS_PLUGINS_DIR} pantheon-systems/terminus-rsync-plugin \
    && composer -n create-project --no-dev -d ${TERMINUS_PLUGINS_DIR} pantheon-systems/terminus-composer-plugin \
    && composer clearcache
ENV PATH=${PATH}:${TERMINUS_DIR}/vendor/bin
RUN mkdir -p $HOME/.ssh \
    && echo "StrictHostKeyChecking no" >> "$HOME/.ssh/config" \
    && echo "ControlMaster auto" >> "$HOME/.ssh/config" \
    && echo "ControlPath ~/.ssh/_%C" >> "$HOME/.ssh/config" \
    && echo "ControlPersist yes" >> "$HOME/.ssh/config" \
    && chmod 600 $HOME/.ssh/config \
    && terminus --version \
    && robo --version
