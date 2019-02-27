#!/bin/bash
URL=$1
if [ -z "${URL}" ]; then
    echo "URL is not set"
    exit 2
fi

STATUS=$(curl -X GET ${URL})
OUTPUT=$(echo $STATUS | grep -o "\"status\":\"[A-Z]*"| grep -o "[A-Z]*")
if [ -z "${OUTPUT}" ]; then
    echo "can not get status"
    exit 2
fi

if [ "${OUTPUT}" = "OK" ]; then
  exit 0
elif [ "${OUTPUT}" = "WARNING" ]; then
  exit 1
else
  exit 2
fi

exec "$@"
