#!/bin/bash
set -e

sed -i "s!mailhub=mail!mailhub=${RELAY}!g" /etc/ssmtp/ssmtp.conf
sed -i 's!#FromLineOverride=YES!FromLineOverride=YES!g' /etc/ssmtp/ssmtp.conf

{
  chown -fR www-data:www-data /var/www
} || {
  echo "could not change owner"
}

exec "$@"
