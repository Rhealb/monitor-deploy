 # Written by wst

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

# Paths to commands used in this script.
CURL="/usr/bin/curl"
CHECK_URL="http://10.19.140.200:29011/api/v1/query?query=up\{instance=~\"prometheus.*\"\}"
#echo ${CHECK_URL}
CHECK_PROMETHEUS="Prometheus"

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
        echo "$PROGNAME $RELEASE - Prometheus status check script for Nagios"
        echo ""
        echo "Usage: check_prometheus_status.sh"
        echo ""
        echo "  -H  the host(default:http://10.19.140.200:30092)"
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
        echo "This plugin will check Prometheus status"
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
            CHECK_URL="http://${host}/api/v1/query?query=up\{instance=~\"prometheus.*\"\}"
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
		
	    #echo `$CURL --insecure -m 5 -s -w "#HTTPSTATUS:%{http_code}" $CHECK_URL`
        CURL_RETURN=`$CURL --insecure -m 12 -s -w "#HTTPSTATUS:%{http_code}" $CHECK_URL`
        HTTP_STATUS=${CURL_RETURN#*HTTPSTATUS:}
        JSON_SCRIPT=${CURL_RETURN%#HTTPSTATUS:*}

        if [ "${HTTP_STATUS}" = "200" ];then
			JSON_SCRIPT_FILTER=$(echo ${JSON_SCRIPT} | sed 's/[0-9]*\.[0-9]*,'//g)
        	JSON_SCIRIPT_MATCH=$(echo ${JSON_SCRIPT_FILTER} | grep -o '"value":\["[0-9]"\]')        	
			
			for cur_str in ${JSON_SCRIPT_MATCH}
			do
		    	status=$(echo ${cur_str} | grep -o '[0-9]')
				if ["${status}" != "1"];then
                	echo "CRITICAL - $CHECK_PROMETHEUS status is CRITICAL"
                	exit $STATE_CRITICAL
				fi	
			done
			
			echo "OK - $CHECK_PROMETHEUS status is OK"
            exit $STATE_OK
		else
            echo "CRITICAL - HTTP_RESPONSE status code is $HTTP_STATUS"
            exit $STATE_CRITICAL	
        fi
