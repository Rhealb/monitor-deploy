# Written by wst

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

# Paths to commands used in this script.
CURL="/usr/bin/curl"
CHECK_URL="http://10.19.140.200:29430/api/stats"
CHECK_OPENTSDB="OpenTSDB"

JVM_USAGE_THRESHOLD=90

# USERNAME="IDH02BjXJI8agb1WdPlXf3VaYkRVNQrPaP5OKcbuYe8="
# PASSWD="admin"

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
        echo "$PROGNAME $RELEASE - OpenTSDB status check script for Nagios"
        echo ""
        echo "Usage: check_opentsdb_status.sh"
        echo ""
        echo "  -H  the host(default:http://10.19.140.200:30142)"
        # echo "  -n  username to login(default:admin)"
        # echo "  -p  passwd to login(default:admin)"
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
        echo "This plugin will check opentsdb status"
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
            CHECK_URL="http://${host}/api/stats"
            ;;
        -THRESHOLD | --JVM_USAGE_THRESHOLD)
            JVM_USAGE_THRESHOLD=${1}
            ;;
       # -n | --username)
       #     shift
       #     USERNAME=$1
       #    ;;
       # -p | --password)
       #     shift
       #     PASSWD=$1
       #     ;;
        *)

        echo "Unknown argument: $1"
            print_usage
            exit $STATE_UNKNOWN
            ;;
        esac
shift
done
        
CURL_RETURN=`$CURL --insecure -m 7 -s -w "#HTTPSTATUS:%{http_code}" $CHECK_URL`
HTTP_STATUS=$(echo ${CURL_RETURN} | awk -F"#HTTPSTATUS:" '{print $2}')

if [ "$HTTP_STATUS" != "200" ];then
    CURL_RETURN=`$CURL --insecure -XGET -m 7 -s -w "#HTTPSTATUS:%{http_code}" $CHECK_URL`
    HTTP_STATUS=$(echo ${CURL_RETURN} | awk -F"#HTTPSTATUS:" '{print $2}')
fi

if [ "$HTTP_STATUS" = "200" ];then
    JSON_SCRIPT=${CURL_RETURN%#HTTPSTATUS:*}
    jvm_ramused=`echo $JSON_SCRIPT | grep -o '"metric":"tsd.jvm.ramused","timestamp":[0-9]*,"value":"[0-9]*' | grep -o 'value":"[0-9]*' | grep -o '[0-9]*'`
    jvm_ramfree=`echo $JSON_SCRIPT | grep -o '"metric":"tsd.jvm.ramfree","timestamp":[0-9]*,"value":"[0-9]*' | grep -o 'value":"[0-9]*' | grep -o '[0-9]*'`

    jvm_sum=$[${jvm_ramfree}+${jvm_ramused}]
    usage_rate=$(awk 'BEGIN{printf "%.2f\n",'${jvm_ramused}'/'${jvm_sum}*100'}')

    if [ $( echo "${usage_rate} ${JVM_USAGE_THRESHOLD}" | awk '{if($1<$2) {print 0} else {print 1}}' ) -eq 0 ];then
        echo "OK - $CHECK_OPENTSDB status is green"
        exit $STATE_OK
    else
        echo "WARNING - HTTP_RESPONSE status code is $HTTP_STATUS"
        exit $STATE_WARNING
    fi
else
    echo "CRITICAL - HTTP_RESPONSE status code is $HTTP_STATUS"
    exit $STATE_CRITICAL
fi