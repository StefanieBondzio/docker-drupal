FROM debian:jessie
MAINTAINER LWB

ENV HOST=HOST \
    RELAY=RELAY \
    DOMAIN=DOMAIN \
    DRUSH_VERSION=8 \
    PHP_VERSION=7.0

COPY cgi.list /etc/apt/sources.list.d/

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes --no-install-recommends \
    apache2-mpm-event libapache2-mod-fastcgi \
    mysql-client \
    apt-transport-https \
    curl wget bsd-mailx ca-certificates \
    git zip unzip \
    supervisor \
    postfix

COPY dotdeb.list /etc/apt/sources.list.d/

RUN curl http://www.dotdeb.org/dotdeb.gpg | apt-key add -

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes --no-install-recommends \
    php${PHP_VERSION}-fpm php${PHP_VERSION}-gd php${PHP_VERSION}-mysql php${PHP_VERSION}-sybase php${PHP_VERSION}-mbstring php${PHP_VERSION}-xml php${PHP_VERSION}-curl php${PHP_VERSION}-memcache php${PHP_VERSION}-json php${PHP_VERSION}-zip php${PHP_VERSION}-apc php${PHP_VERSION}-soap php${PHP_VERSION}-ldap \
    php${PHP_VERSION}-dev make

RUN a2enmod rewrite expires actions fastcgi headers alias && \
    echo 'extension=uploadprogress.so' >> /etc/php/${PHP_VERSION}/fpm/php.ini && \
    echo 'opcache.memory_consumption = 256' >> /etc/php/${PHP_VERSION}/fpm/php.ini && \
    echo 'opcache.max_accelerated_files = 4000' >> /etc/php/${PHP_VERSION}/fpm/php.ini && \
    echo 'opcache.revalidate_freq = 240' >> /etc/php/${PHP_VERSION}/fpm/php.ini && \
    echo 'opcache.fast_shutdown = 1' >> /etc/php/${PHP_VERSION}/fpm/php.ini && \
    echo 'apc.rfc1867 = 1' >> /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i 's!upload_max_filesize = 2M!upload_max_filesize = 20M!g' /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i 's!post_max_size = 8M!post_max_size = 20M!g' /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i 's!memory_limit = 128M!memory_limit = 256M!g' /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i 's!; max_input_vars = 1000!max_input_vars = 5000!g' /etc/php/${PHP_VERSION}/fpm/php.ini && \
    echo '[topdesk1]\n\thost = topdesk1.lwb.local\n\tport = 1433\n\ttds version = 8.0\n' >> /etc/freetds/freetds.conf

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    mkdir /opt/drush-${DRUSH_VERSION} && \
    cd /opt/drush-${DRUSH_VERSION} && \
    composer init --require=drush/drush:${DRUSH_VERSION}.* -n && \
    composer config bin-dir /usr/local/bin && \
    composer install

RUN git clone https://git.php.net/repository/pecl/php/uploadprogress.git && \
    cd uploadprogress && \
    phpize${PHP_VERSION} && \
    ./configure && \
    make && \
    make install && \
    touch /etc/php/${PHP_VERSION}/mods-available/uploadprogress.ini && \
    echo '; configuration for php uploadprogress module' >> /etc/php/${PHP_VERSION}/mods-available/uploadprogress.ini && \
    echo '; priority=20' >> /etc/php/${PHP_VERSION}/mods-available/uploadprogress.ini && \
    echo 'extension=uploadprogress.so' >> /etc/php/${PHP_VERSION}/mods-available/uploadprogress.ini && \
    phpenmod uploadprogress

RUN rm -f /var/www/html/index.html && \
    apt-get remove --purge -y php${PHP_VERSION}-dev make && \
    apt-get autoremove --purge -y && \
    rm -rf /var/lib/apt/lists && \
    rm -rf /var/tmp/* && \
    rm -rf /tmp/* 

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY 000-default.conf /etc/apache2/sites-available/
COPY php${PHP_VERSION}-fpm.conf /etc/apache2/conf-available/

VOLUME /var/www/html
WORKDIR /var/www/html

RUN touch /usr/lib/cgi-bin/php${PHP_VERSION}.fcgi && \
    chown -R www-data:www-data /usr/lib/cgi-bin && \
    a2enconf php${PHP_VERSION}-fpm && \
    a2enmod proxy_fcgi setenvif

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 80

CMD ["/usr/bin/supervisord"]
