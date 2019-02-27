#!/bin/bash

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

# Plugin variable description
PROGNAME=$(basename $0)
RELEASE="Revision 0.1"
AUTHOR="(c) 2017 WeiZe (ze.wei1989@gmail.com)"

host=""
port=""
timeout=5

# Functions plugin usage
print_release() {
    echo "$RELEASE $AUTHOR"
}

print_usage() {
        echo ""
        echo "$PROGNAME $RELEASE - Spark-Job status check script"
        echo ""
        echo "Usage: check_spark_job.sh"
        echo ""
        echo "  -H host"
        echo "  -T timeout"
        echo "  -v  check the version"
        echo "  -h  Show this page"
        echo ""
    echo "Usage: $PROGNAME"
    echo "Usage: $PROGNAME --help"
    echo ""
    exit 0
}

print_help() {
        print_usage
        echo ""
        echo "This plugin will check hdfs status"
        echo ""
        exit 0
}

# Parse parameters
while [ $# -gt 0 ]; do
    case "$1" in
        -h | --help)
            print_help
            exit $STATE_OK
            ;;
        -v | --version)
            print_release
            exit $STATE_OK
            ;;
        -H | --host)
            shift
            host=$1
            ;;
        -P | --port)
            shift
            port=$1
            ;;
        -T | --timeout)
            shift
            timeout=$1
            ;;
        *)

        echo "Unknown argument: $1"
            print_usage
            exit $STATE_UNKNOWN
            ;;
        esac
shift
done


curl_result=`curl -m $timeout -w "%{http_code}" -s http://$host:$port/api/v1/applications`
http_status=${curl_result:0-3}
echo "http://$host:$port/api/v1/applications"
if [[ $http_status -ne 200 ]]; then
  echo "/api/vi/applications response code not 200"
  exit $STATE_CRITICAL
fi
length=${#curl_result}
json_length=`expr $length - 3`
json_str=${curl_result:0:$json_length}
app_id=`echo $json_str | ./jq -r '.[0] .id'`
echo "http://$host:$port/api/v1/applications/$app_id/jobs?status=succeeded"

curl_result=`curl -m $timeout -w "%{http_code}" -s http://$host:$port/api/v1/applications/$app_id/jobs?status=succeeded`
http_status=${curl_result:0-3}
if [[ $http_status -ne 200 ]]; then
  echo "/api/vi/applications/$app_id/jobs response code not 200"
  exit $STATE_CRITICAL
fi
length=${#curl_result}
json_length=`expr $length - 3`
json_str=${curl_result:0:$json_length}
completion_time=`echo $json_str | ./jq -r '.[0] .completionTime'`

completion_timestamp=`date -d $completion_time +%s`
current_timestamp=`date +%s`
timespan=`expr $current_timestamp - $completion_timestamp`
if [[ $timespan -gt 120 && $timespan -le 300 ]]; then
  exit $STATE_WARNING
elif [[ $timespan -gt 300 ]]; then
  exit $STATE_CRITICAL
else
  exit $STATE_OK
fi
