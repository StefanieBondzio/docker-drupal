FROM debian:jessie
MAINTAINER LWB <thomas.heyl@lwb.de>

RUN apt-get update && \
    apt-get install -y --force-yes --no-install-recommends libapache2-mod-php5 php5-gd php5-mysql php5-sybase php5-ldap php5-dev php5-curl php5-memcache php5-json php-pear make wget drush && \
    apt-get install -y --force-yes --no-install-recommends imagemagick texinfo dvi2ps ghostscript texlive-generic-recommended texlive-lang-german texlive-latex-recommended texlive-latex-extra texlive-fonts-extra texlive-fonts-recommended texlive-math-extra gnuhtml2latex && \
    a2enmod rewrite && \
    a2enmod expires && \
    pecl install uploadprogress && \
    echo 'extension=uploadprogress.so' >> /etc/php5/apache2/php.ini && \
    echo 'opcache.memory_consumption = 128' >> /etc/php5/apache2/php.ini && \
    echo 'opcache.max_accelerated_files = 4000' >> /etc/php5/apache2/php.ini && \
    echo 'opcache.revalidate_freq = 240' >> /etc/php5/apache2/php.ini && \
    echo '[topdesk1]\n\thost = topdesk1.lwb.local\n\tport = 1433\n\ttds version = 8.0\n' >> /etc/freetds/freetds.conf && \
    rm -f /var/www/html/index.html && \
    apt-get -y --purge remove php5-dev make && \ 
    apt-get -y --purge autoremove && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists && \
    rm -rf /var/tmp/* && \
    rm -rf /tmp/* 

COPY 000-default.conf /etc/apache2/sites-available/

EXPOSE 80
VOLUME /var/www/html

CMD chown -R www-data:www-data /var/www && \
    service apache2 restart && \
    /bin/bash