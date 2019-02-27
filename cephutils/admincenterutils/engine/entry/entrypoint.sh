#!/bin/bash

#------------------------------  To set the s3config  ----------------------------------------------#
if [ "${UtilsStoreType}" == "S3" ]; then
  S3CMD=`which s3cmd`

  if [[ -z ${S3CMD} ]]; then
    echo "please install binary s3cmd"
    exit 1
  fi

  if [ ! -f ~/.s3cfg ]; then
    echo "Error: s3cfg connot exist......"
    exit 1
  fi

  # To decode the access_key 
  echo "${ACCESS_KEY}" >> /tmp/access_key_base64.txt
  openssl enc -base64 -d -in /tmp/access_key_base64.txt -out /tmp/access_key_encrypted.txt
  openssl enc -d -p -des3 -pass pass:Maserati -S 88888888 -in /tmp/access_key_encrypted.txt -out /tmp/access_key_plain.txt
  access_key=$(cat /tmp/access_key_plain.txt)

  if [ -f /tmp/access_key_base64.txt ]; then
    rm /tmp/access_key_base64.txt
  fi

  if [ -f /tmp/access_key_encrypted.txt ]; then
    rm /tmp/access_key_encrypted.txt
  fi

  if [ -f /tmp/access_key_plain.txt ]; then
    rm /tmp/access_key_plain.txt
  fi


  # To decode the secret_key
  echo "${SECRET_KEY}" >> /tmp/secret_key_base64.txt
  openssl enc -base64 -d -in /tmp/secret_key_base64.txt -out /tmp/secret_key_encrypted.txt
  openssl enc -d -p -des3 -pass pass:Maserati -S 88888888 -in /tmp/secret_key_encrypted.txt -out /tmp/secret_key_plain.txt
  secret_key=$(cat /tmp/secret_key_plain.txt)

  if [ -f /tmp/secret_key_base64.txt ]; then
    rm /tmp/secret_key_base64.txt
  fi

  if [ -f /tmp/secret_key_encrypted.txt ]; then
    rm /tmp/secret_key_encrypted.txt
  fi

  if [ -f /tmp/secret_key_plain.txt ]; then
    rm /tmp/secret_key_plain.txt
  fi

  # To config the s3cfg
  config=$(cd `dirname ~/.s3cfg`; pwd)
  s3cfg=${config}/.s3cfg

  sed -i '/host_bucket/d' ${s3cfg}
  sed -i '/host_base/d' ${s3cfg}
  echo "host_base = ${HOST_BASE}" >> ${s3cfg}
  echo "host_bucket = ${HOST_BUCKET}" >> ${s3cfg}

  sed -i '/access_key/d' ${s3cfg}
  echo "access_key = ${access_key}" >> ${s3cfg}
  sed -i '/secret_key/d' ${s3cfg}
  echo "secret_key = ${secret_key}" >> ${s3cfg}

  # To verify whether or not the configuration of s3cfg is correct
  `${S3CMD} ls > /dev/null`
  if [ $? -ne 0 ]; then
    echo "Error: s3cdm config error..."
    exit 1
  fi
fi
#-------------------------------------------------------------------------------------------------------------------------------------#

# To start cron
service cron start

# To set timing work
FILEPATH="/etc/crontab"

echo '30 1 * * * root /bin/bash /opt/timing-delete.sh >> /opt/prometheus-1.5.2.linux-amd64/daily_clean.log 2>&1 ' >> ${FILEPATH}

if [ ! -d "/opt/mntcephutils/engine/prometheus/" ];then
  mkdir -p /opt/mntcephutils/engine/prometheus
fi


# if use s3 to sync config and data, start engine-amah and check thread
if [ "${UtilsStoreType}" == "S3" ]; then
  nohup /bin/engine-amah -cephpath="/opt/mntcephutils/engine" \
                 -prometheus="localhost:9090" \
                 -syncinterval=${SYNCINTERVAL} \
                 -s3bucket=${S3BUCKET} \
                 -s3key=${S3KEY} \
                 -timeout=${TIMEOUT} >> /opt/log.txt 2>&1 &

  while [ 1 ]; do
    nc -w 3 -zv localhost 8092 >> /opt/log.txt 2>&1
    result=$?

    if [ "${result}" == "0" ]; then
      chmod +x /opt/mntcephutils/engine/scripts/check_heart.sh
      nohup /opt/mntcephutils/engine/scripts/check_heart.sh >> /opt/log.txt 2>&1 &
      break
    fi
  done
fi


# sleep 36000000

# To start prometheus engine
/opt/prometheus-1.5.2.linux-amd64/prometheus -config.file=/opt/mntcephutils/engine/conf/config.yml \
                                             -storage.local.path=/opt/mntcephutils/engine/prometheus \
                                             -storage.local.retention=${RETAIN_TIME} \
                                             -web.console.libraries=/opt/prometheus-1.5.2.linux-amd64/console_libraries \
                                             -web.console.templates=/opt/prometheus-1.5.2.linux-amd64/consoles \

