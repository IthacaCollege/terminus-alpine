FROM drupaldocker/php:7.2-cli-2.x
ENV TERMINUS_VERSION=1 \
    TERMINUS_HIDE_UPDATE_MESSAGE=1.9 \
    TERMINUS_DIR=/usr/local/share/terminus \
    TERMINUS_PLUGINS_DIR=/usr/local/share/terminus-plugins \
    TZ=America/New_York
COPY set-environment /usr/local/bin/set-environment
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && apk upgrade --no-cache \
    && apk add --no-cache --upgrade bash git moreutils patch \
    && composer -n global require -n "hirak/prestissimo:^0.3" \
    && mkdir -p $TERMINUS_DIR \
    && mkdir -p $TERMINUS_PLUGINS_DIR 
RUN composer -n --working-dir=$TERMINUS_DIR require pantheon-systems/terminus:^$TERMINUS_VERSION \
    && composer -n create-project -d $TERMINUS_PLUGINS_DIR pantheon-systems/terminus-build-tools-plugin:^1 \
    && composer -n create-project -d $TERMINUS_PLUGINS_DIR pantheon-systems/terminus-secrets-plugin:^1 \
    && composer -n create-project -d $TERMINUS_PLUGINS_DIR pantheon-systems/terminus-rsync-plugin:^1 \
    && composer -n create-project -d $TERMINUS_PLUGINS_DIR pantheon-systems/terminus-composer-plugin:^1 \
    && composer clearcache
ENV PATH=$PATH:$TERMINUS_DIR/vendor/bin
RUN mkdir -p $HOME/.ssh \
    && echo "StrictHostKeyChecking no" >> "$HOME/.ssh/config" \
    && echo "ControlMaster auto" >> "$HOME/.ssh/config" \
    && echo "ControlPath ~/.ssh/_%C" >> "$HOME/.ssh/config" \
    && echo "ControlPersist yes" >> "$HOME/.ssh/config"
RUN chmod 600 $HOME/.ssh/config
