#!/bin/bash
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

# Paths to commands used in this script.
CURL="/usr/bin/curl"
CHECK_URL="http://10.19.140.200:29101/api/v0.1/health"
CHECK_CEPH_CLOCK="ceph_clock"
DEFAULT_PORT=":29101/api/v0.1/health"

# Plugin variable description
PROGNAME=$(basename $0)
RELEASE="Revision 0.1"
AUTHOR="(c) 2017 WangShengtao (stwang.casd@gmail.com)"

# Functions plugin usage
print_release() {
    echo "$RELEASE $AUTHOR"
}

print_usage() {
        echo ""
        echo "$PROGNAME $RELEASE - ceph status check script for Nagios"
        echo ""
        echo "Usage: check_ceph_status.sh -H"
        echo ""
        echo "  -H  specify host address(eg:http://10.19.132.177:6789)"
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
        echo "This plugin will check ceph status"
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
        -H | --hostaddres)
            shift
            CHECK_URL="http://${1}$DEFAULT_PORT"
            ;;
    *)
        echo "Unknown argument: $1"
            print_usage
            exit $STATE_UNKNOWN
            ;;
        esac
shift
done

CURL_RETURN=`$CURL --insecure -m 5 -s -w "#HTTPSTATUS:%{http_code}" $CHECK_URL`

HTTP_STATUS=$(echo ${CURL_RETURN} | awk -F"#HTTPSTATUS:" '{print $2}')
JSON_SCRIPT=${CURL_RETURN%#HTTPSTATUS:*}


if [ "${HTTP_STATUS}" = "200" ];then
    warnStatus=0
    warnStatus=`echo ${JSON_SCRIPT} | grep -o "clock skew detected" | wc -l`

    if [[ ${warnStatus} == 1 ]]; then
        #statements
        echo "WARNING - $CHECK_CEPH_CLOCK status is WARNING"
        exit $STATE_WARNING
    fi

    echo "OK - $CHECK_CEPH_CLOCK status is OK"
    exit $STATE_OK
else
    echo "CRITICAL - HTTP_RESPONSE status code is $HTTP_STATUS"
    exit $STATE_CRITICAL
fi

