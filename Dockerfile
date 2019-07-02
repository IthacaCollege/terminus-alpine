FROM php:7.1-cli-alpine
ENV TERMINUS_VERSION=2 TERMINUS_HIDE_UPDATE_MESSAGE=1 TERMINUS_DIR=/usr/local/share/terminus TERMINUS_PLUGINS_DIR=/usr/local/share/terminus-plugins
RUN wget -O /usr/local/bin/composer https://getcomposer.org/composer.phar \
    && chmod +x /usr/local/bin/composer \
    && apk add --no-cache git \
    && composer -n global require -n "hirak/prestissimo:^0.3" \
    && mkdir -p $TERMINUS_DIR \
    && composer -n --working-dir=$TERMINUS_DIR require pantheon-systems/terminus:^$TERMINUS_VERSION \
    && mkdir -p $TERMINUS_PLUGINS_DIR \
    && composer -n create-project -d $TERMINUS_PLUGINS_DIR pantheon-systems/terminus-build-tools-plugin:^1 \
    && composer -n create-project -d $TERMINUS_PLUGINS_DIR pantheon-systems/terminus-secrets-plugin:^1 \
    && composer -n create-project -d $TERMINUS_PLUGINS_DIR pantheon-systems/terminus-rsync-plugin:^1 \
    && composer -n create-project -d $TERMINUS_PLUGINS_DIR pantheon-systems/terminus-quicksilver-plugin:^1 \
    && composer -n create-project -d $TERMINUS_PLUGINS_DIR pantheon-systems/terminus-composer-plugin:^1 \
    && composer -n create-project -d $TERMINUS_PLUGINS_DIR pantheon-systems/terminus-drupal-console-plugin:^1 \
    && composer -n create-project -d $TERMINUS_PLUGINS_DIR pantheon-systems/terminus-mass-update:^1 \
    && composer -n create-project -d $TERMINUS_PLUGINS_DIR pantheon-systems/terminus-site-clone-plugin:^1 \
    && composer clearcache
