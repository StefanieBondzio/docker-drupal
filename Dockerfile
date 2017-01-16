FROM debian:jessie
MAINTAINER LWB

ENV HOST=HOST \
    RELAY=RELAY \
    DOMAIN=DOMAIN

COPY cgi.list /etc/apt/sources.list.d/

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes --no-install-recommends \
    apache2-mpm-event libapache2-mod-fastcgi \
    apt-transport-https \
    curl wget bsd-mailx ca-certificates \
    git zip unzip \
    supervisor \
    postfix

COPY dotdeb.list /etc/apt/sources.list.d/

RUN curl http://www.dotdeb.org/dotdeb.gpg | apt-key add -

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes --no-install-recommends \
    php7.0-fpm php7.0-gd php7.0-mysql php7.0-sybase php7.0-mbstring php7.0-xml php7.0-curl php7.0-memcache php7.0-json php7.0-apc

RUN a2enmod rewrite expires actions fastcgi headers alias && \
    echo 'extension=uploadprogress.so' >> /etc/php/7.0/fpm/php.ini && \
    echo 'opcache.memory_consumption = 256' >> /etc/php/7.0/fpm/php.ini && \
    echo 'opcache.max_accelerated_files = 4000' >> /etc/php/7.0/fpm/php.ini && \
    echo 'opcache.revalidate_freq = 240' >> /etc/php/7.0/fpm/php.ini && \
    echo 'opcache.fast_shutdown = 1' >> /etc/php/7.0/fpm/php.ini && \
    sed -i 's!upload_max_filesize = 2M!upload_max_filesize = 20M!g' /etc/php/7.0/fpm/php.ini && \
    sed -i 's!post_max_size = 8M!post_max_size = 20M!g' /etc/php/7.0/fpm/php.ini && \
    sed -i 's!memory_limit = 128M!memory_limit = 256M!g' /etc/php/7.0/fpm/php.ini && \
    sed -i 's!; max_input_vars = 1000!max_input_vars = 5000!g' /etc/php/7.0/fpm/php.ini && \
    echo '[topdesk1]\n\thost = topdesk1.lwb.local\n\tport = 1433\n\ttds version = 8.0\n' >> /etc/freetds/freetds.conf

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    mkdir /opt/drush-8 && \
    cd /opt/drush-8 && \
    composer init --require=drush/drush:8.* -n && \
    composer config bin-dir /usr/local/bin && \
    composer install

RUN rm -f /var/www/html/index.html && \
    rm -rf /var/lib/apt/lists && \
    rm -rf /var/tmp/* && \
    rm -rf /tmp/* 

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY 000-default.conf /etc/apache2/sites-available/
COPY php7.0-fpm.conf /etc/apache2/conf-available/

VOLUME /var/www/html
WORKDIR /var/www/html

RUN touch /usr/lib/cgi-bin/php7.fcgi && \
    chown -R www-data:www-data /usr/lib/cgi-bin && \
    a2enconf php7.0-fpm setenvif && \
    a2enmod proxy_fcgi setenvif

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 80

CMD ["/usr/bin/supervisord"]
