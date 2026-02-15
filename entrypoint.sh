#!/bin/bash

# set -e

set -euo pipefail
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
echo $TZ > /etc/timezone


declare -p | grep -Ev 'BASHOPTS|BASH_VERSINFO|EUID|PPID|SHELLOPTS|UID' > /etc/container.env
chmod 0644 /etc/container.env

# Default to running every day at midnight if not provided
# SCHEDULE=${CRON_SCHEDULE:-"0 0 * * *"}

# Add the cron job to the crontab
# echo "SHELL=/bin/bash" > /etc/cron.d/testssl
# echo "BASH_ENV=/etc/container.env" >> /etc/cron.d/testssl
# echo "$SCHEDULE . /etc/container.env; /usr/local/bin/runner.sh >> /var/log/cron.log 2>&1" >> /etc/cron.d/testssl
# echo -e "\n" >> /etc/cron.d/testssl
# chmod 0644 /etc/cron.d/testssl
chown root:root /etc/cron.d/mycron
chmod 0644 /etc/cron.d/mycron
crontab /etc/cron.d/mycron


echo "mailhub=$EMAIL_SERVER" > /etc/ssmtp/ssmtp.conf
echo "RewriteDomain=$EMAIL_DOMAIN" >> /etc/ssmtp/ssmtp.conf

ln -sf /proc/1/fd/1 /var/log/cron.log

# Start cron in the background and tail logs to keep container alive
printenv > /etc/environment # Ensure cron sees env variables
echo "Launching supervisor..."
/usr/bin/supervisord -c /data/supervisor.conf

