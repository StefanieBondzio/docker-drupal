#!/bin/bash
set -e

postconf -e myhostname=${HOST}\.${DOMAIN}
postconf -e mydestination="root@${HOST}.${DOMAIN}, ${HOST}.${DOMAIN}, localhost.${DOMAIN}"
postconf -e relayhost=${RELAY}\.${DOMAIN}

service postfix restart

chown -R www-data:www-data /var/www

exec "$@"