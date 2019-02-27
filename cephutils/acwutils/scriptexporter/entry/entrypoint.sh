#!/bin/bash

#------------------------------  To set the s3config  ----------------------------------------------#
if [ "${STORAGE_TYPE}" == "S3" ]; then
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

mkdir -p ${WORKSPACE}
cp -r ${CEPHPATH}/* ${WORKSPACE}
chmod -R a+x ${WORKSPACE}

# To start script-exporter
/bin/script_exporter  -config.shell=/bin/bash \
                      -config.workspace=${WORKSPACE} \
                      -config.cephpath=${CEPHPATH} \
                      -mysql.url=${MYSQLSERVER} \
                      -storage-type=${STORAGE_TYPE} \
                      -s3bucket=${S3BUCKET} \
                      -s3key=${S3KEY} \
                      -timeout=${TIMEOUT}