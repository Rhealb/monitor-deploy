#!/bin/bash
set -e
AMAH_HOME=/opt/amah-mysql
AMAH_CONF=${AMAH_HOME}/conf
AMAH_LIBS=${AMAH_HOME}/libs
CONF_FILE_NAME="mysql.properties"
AMAH_CONF_FILE=${AMAH_CONF}/${CONF_FILE_NAME}

if [ -z "$BD_MYSQL_SERVER" ]; then
    echo "\$BD_MYSQL_SERVER not set"
    exit 1
fi

if [ -z "$BD_MYSQL_USERNAME" ]; then
    echo "\$BD_MYSQL_USERNAME not set"
    exit 1
fi

if [ -z "$BD_MYSQL_PASSWORD" ]; then
    echo "\$BD_MYSQL_PASSWORD not set"
    exit 1
fi

function replacePrefix {
  sed -i "s/%BD_MYSQL_SERVER%/${BD_MYSQL_SERVER}/g" ${AMAH_CONF_FILE}
  sed -i "s/%BD_MYSQL_USERNAME%/${BD_MYSQL_USERNAME}/g" ${AMAH_CONF_FILE}
  sed -i "s/%BD_MYSQL_PASSWORD%/${BD_MYSQL_PASSWORD}/g" ${AMAH_CONF_FILE}
}
cp -f /opt/mntcephutils/conf/${CONF_FILE_NAME} ${AMAH_CONF}
replacePrefix
java -Xmx512m -cp "${AMAH_LIBS}/*" io.helium.amah.cli.CliMain ${AMAH_CONF_FILE}
