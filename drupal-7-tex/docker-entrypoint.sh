#!/bin/bash
set -e

sed -i "s/myhostname =.*/myhostname = ${HOST}\.${DOMAIN}/g" /etc/postfix/main.cf
sed -i "s/mydestination =.*/mydestination = root@${HOST}\.${DOMAIN}, ${HOST}\.${DOMAIN}, localhost\.${DOMAIN}, localhost/g" /etc/postfix/main.cf
sed -i "s/relayhost =.*/relayhost = ${RELAY}\.${DOMAIN}/g" /etc/postfix/main.cf