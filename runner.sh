#!/bin/bash
# Path to your input files
DOMAINS="/data/domains.txt"
EMAIL_FILE="/data/email.txt"
EMAIL_ADDRESS="/data/emailaddress.txt"

cd /data || exit 1

# Clear/Initialize the log file
echo "" > /data/grade.log

while IFS= read -r line; do
     # Skip empty lines in domains.txt
     [[ -z "$line" ]] && continue
     
     # Capture the grade into a variable
     GRADE=$(testssl --quiet --color 0 "$line" | grep "Overall Grade" | awk '{print $NF}')
     
     # If GRADE is empty (scan failed), provide a fallback message
     GRADE=${GRADE:-"Scan Failed/No Grade"}

     # Print domain and grade on the same line
     echo "$line: $GRADE" >> /data/grade.log

     TIMESTAMP=$(date +%Y%m%d_%H%M)
     echo "Scan completed at $TIMESTAMP for $line" >> /data/cron_history.log

done < "$DOMAINS"

# Combine email body and grades
cat /data/email.txt /data/grade.log > /data/emailout.log

# Send the email
/usr/sbin/ssmtp "$(cat $EMAIL_ADDRESS)" < /data/emailout.log
