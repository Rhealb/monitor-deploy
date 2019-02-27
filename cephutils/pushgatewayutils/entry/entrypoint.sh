
# To start cron
service cron start

# To set timing work
FILEPATH="/etc/crontab"

echo '0 */4 * * * root /bin/bash /opt/prometheus-pushgateway/timing_delete.sh >> /opt/prometheus-pushgateway/daily_clean.log 2>&1 ' >> ${FILEPATH}

# To start pushgateway
/opt/pushgateway-0.3.1.linux-amd64/pushgateway