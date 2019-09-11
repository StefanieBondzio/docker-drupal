FROM debian:stretch
MAINTAINER LWB

ENV RELAY=RELAY \
    DRUSH_VERSION=8 \
    PHP_VERSION=7.0 \
    TIKA=tika-app-1.22.jar

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes --no-install-recommends \
    mysql-client \
    apt-transport-https \
    curl wget \
    ca-certificates \
    ssmtp \
    git zip unzip \
    openjdk-8-jre-headless \
    libreoffice-writer \
    tesseract-ocr tesseract-ocr-deu \
    ffmpeg \
    apache2 libapache2-mod-php7.0 \
    php${PHP_VERSION}-gd php${PHP_VERSION}-mysql php${PHP_VERSION}-sybase php${PHP_VERSION}-mbstring php${PHP_VERSION}-xml php${PHP_VERSION}-curl php${PHP_VERSION}-memcache php${PHP_VERSION}-json php${PHP_VERSION}-zip php${PHP_VERSION}-apc php${PHP_VERSION}-soap php${PHP_VERSION}-ldap \
    php-uploadprogress

RUN a2enmod rewrite expires actions headers alias && \
    echo 'extension=uploadprogress.so' >> /etc/php/${PHP_VERSION}/apache2/php.ini && \
    echo 'opcache.memory_consumption = 512' >> /etc/php/${PHP_VERSION}/apache2/php.ini && \
    echo 'opcache.max_accelerated_files = 4000' >> /etc/php/${PHP_VERSION}/apache2/php.ini && \
    echo 'opcache.revalidate_freq = 240' >> /etc/php/${PHP_VERSION}/apache2/php.ini && \
    echo 'opcache.fast_shutdown = 1' >> /etc/php/${PHP_VERSION}/apache2/php.ini && \
    echo 'apc.rfc1867 = 1' >> /etc/php/${PHP_VERSION}/apache2/php.ini && \
    sed -i 's!upload_max_filesize = 2M!upload_max_filesize = 512M!g' /etc/php/${PHP_VERSION}/apache2/php.ini && \
    sed -i 's!post_max_size = 8M!post_max_size = 512M!g' /etc/php/${PHP_VERSION}/apache2/php.ini && \
    sed -i 's!memory_limit = 128M!memory_limit = 512M!g' /etc/php/${PHP_VERSION}/apache2/php.ini && \
    sed -i 's!; max_input_vars = 1000!max_input_vars = 5000!g' /etc/php/${PHP_VERSION}/apache2/php.ini && \
    sed -i 's!;sendmail_path =!sendmail_path = /usr/sbin/ssmtp -t!g' /etc/php/${PHP_VERSION}/apache2/php.ini && \
    echo '[php]\n\thost = php.lwb.local\n\tport = 1433\n\ttds version = 8.0\n' >> /etc/freetds/freetds.conf

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    mkdir /opt/drush-${DRUSH_VERSION} && \
    cd /opt/drush-${DRUSH_VERSION} && \
    composer init --require=drush/drush:${DRUSH_VERSION}.* -n && \
    composer config bin-dir /usr/local/bin && \
    composer install

RUN rm -f /var/www/html/index.html && \
    mkdir -p /var/www/html/web && \
    rm -rf /var/lib/apt/lists && \
    rm -rf /var/tmp/* && \
    rm -rf /tmp/* 

RUN wget http://mirror.netcologne.de/apache.org/tika/${TIKA} && \
    mkdir -p /var/www/vendor && \
    mv ${TIKA} /var/www/vendor/

RUN mkdir -p /var/www/.config/libreoffice/4/user
COPY registrymodifications.xcu /var/www/.config/libreoffice/4/user/
RUN chmod o+r /var/www/.config/libreoffice/4/user/registrymodifications.xcu

COPY 000-default.conf /etc/apache2/sites-available/

VOLUME /var/www/html
WORKDIR /var/www/html/web

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 80

CMD /usr/sbin/apache2ctl -D FOREGROUND
