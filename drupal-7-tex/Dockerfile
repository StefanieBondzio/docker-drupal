FROM debian:jessie
MAINTAINER LWB <thomas.heyl@lwb.de>

COPY cgi.list /etc/apt/sources.list.d/

RUN apt-get update && \
    apache2-mpm-event libapache2-mod-fastcgi \
    php5-fpm php5-gd php5-mysql php5-sybase php5-ldap php5-dev php5-curl php5-memcache php5-json php-pear 
    make wget \
    drush supervisor && \
    apt-get install -y --force-yes --no-install-recommends imagemagick texinfo dvi2ps ghostscript texlive-generic-recommended texlive-lang-german texlive-latex-recommended texlive-latex-extra texlive-fonts-extra texlive-fonts-recommended texlive-math-extra gnuhtml2latex && \
    a2enmod rewrite expires actions fastcgi headers alias && \
    pecl install uploadprogress && \
    echo 'extension=uploadprogress.so' >> /etc/php5/fpm/php.ini && \
    echo 'opcache.memory_consumption = 128' >> /etc/php5/fpm/php.ini && \
    echo 'opcache.max_accelerated_files = 4000' >> /etc/php5/fpm/php.ini && \
    echo 'opcache.revalidate_freq = 240' >> /etc/php5/fpm/php.ini && \
    echo '[topdesk1]\n\thost = topdesk1.lwb.local\n\tport = 1433\n\ttds version = 8.0\n' >> /etc/freetds/freetds.conf && \
    rm -f /var/www/html/index.html && \
    apt-get -y --purge remove php5-dev make && \ 
    apt-get -y --purge autoremove && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists && \
    rm -rf /var/tmp/* && \
    rm -rf /tmp/* 

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY 000-default.conf /etc/apache2/sites-available/
COPY php5-fpm.conf /etc/apache2/conf-available/
RUN chown -R www-data:www-data /var/www && \
    touch /usr/lib/cgi-bin/php5.fcgi && \
    chown -R www-data:www-data /usr/lib/cgi-bin && \
    a2enconf php5-fpm

EXPOSE 80
VOLUME /var/www/html

CMD ["/usr/bin/supervisord"]