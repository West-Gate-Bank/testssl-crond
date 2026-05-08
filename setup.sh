#!/bin/bash

# set -e

set -euo pipefail
for e in $(tr "\000" "\n" < /proc/1/environ); do export "$e"; done

echo "myorigin = $EMAIL_DOMAIN" > /etc/postfix/main.cf
echo "relayhost = [$EMAIL_SERVER]"  >> /etc/postfix/main.cf
echo "inet_interfaces = loopback-only" >> /etc/postfix/main.cf
echo "mydestination = " >> /etc/postfix/main.cf
