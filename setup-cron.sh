#!/bin/bash

# set -e

set -euo pipefail
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
echo $TZ > /etc/timezone


declare -p | grep -Ev 'BASHOPTS|BASH_VERSINFO|EUID|PPID|SHELLOPTS|UID' > /etc/container.env
chmod 0644 /etc/container.env

echo "myorigin = $EMAIL_DOMAIN" > /etc/postfix/main.cf
echo "relayhost = [$EMAIL_SERVER]"  >> /etc/postfix/main.cf
echo "inet_interfaces = loopback-only" >> /etc/postfix/main.cf
echo "mydestination = " >> /etc/postfix/main.cf


CRON_FILE="/etc/cron.d/mycron"

if [ -f "$CRON_FILE" ]; then
    echo "Validating crontab..."
    # Copy to ensure correct permissions/ownership for systemd/crond
    chmod 0644 "$CRON_FILE"
    chown root:root "$CRON_FILE"
    
    # Reload crond to ensure it picks up the change
    systemctl reload crond || systemctl restart crond
    echo "Crontab validated and loaded."
else
    echo "Warning: No mounted crontab found at $CRON_FILE"
fi
