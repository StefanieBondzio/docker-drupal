FROM debian:jessie
MAINTAINER LWB

COPY cgi.list /etc/apt/sources.list.d/

ENV HOST=HOST \
    RELAY=RELAY \
    DOMAIN=DOMAIN

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes --no-install-recommends \
    apache2-mpm-event libapache2-mod-fastcgi \
    php5-fpm php5-gd php5-mysql php5-sybase php5-dev php5-curl php5-memcache php5-json php-pear \
    make wget bsd-mailx curl ca-certificates \
    drush git zip unzip \
    supervisor \
    postfix

RUN a2enmod rewrite expires actions fastcgi headers alias && \
    pecl install uploadprogress && \
    echo 'extension=uploadprogress.so' >> /etc/php5/fpm/php.ini && \
    echo 'opcache.memory_consumption = 256' >> /etc/php5/fpm/php.ini && \
    echo 'opcache.max_accelerated_files = 4000' >> /etc/php5/fpm/php.ini && \
    echo 'opcache.revalidate_freq = 240' >> /etc/php5/fpm/php.ini && \
    sed -i 's!upload_max_filesize = 2M!upload_max_filesize = 20M!g' /etc/php5/fpm/php.ini && \
    sed -i 's!post_max_size = 8M!post_max_size = 20M!g' /etc/php5/fpm/php.ini && \
    sed -i 's!memory_limit = 128M!memory_limit = 256M!g' /etc/php5/fpm/php.ini && \
    sed -i 's!; max_input_vars = 1000!max_input_vars = 5000!g' /etc/php5/fpm/php.ini && \
    echo '[topdesk1]\n\thost = topdesk1.lwb.local\n\tport = 1433\n\ttds version = 8.0\n' >> /etc/freetds/freetds.conf
    
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \

RUN rm -f /var/www/html/index.html && \
    apt-get -y --purge remove php5-dev make curl && \ 
    apt-get -y --purge autoremove && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists && \
    rm -rf /var/tmp/* && \
    rm -rf /tmp/* 

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY 000-default.conf /etc/apache2/sites-available/
COPY php5-fpm.conf /etc/apache2/conf-available/

VOLUME /var/www/html
WORKDIR /var/www/html

RUN touch /usr/lib/cgi-bin/php5.fcgi && \
    chown -R www-data:www-data /usr/lib/cgi-bin && \
    a2enconf php5-fpm

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 80

CMD ["/usr/bin/supervisord"]
