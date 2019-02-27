STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

CURL="/usr/bin/curl"
CHECK_URL="http://10.38.240.32:25010/jsonmetrics?json "
CHECK_STATESTORED="Statestored"
NUMBER_OF_IMPALAD=5

PROGNAME=$(basename $0)
RELEASE="Revision 0.1"
AUTHOR="(c) 2017 Yi Ren (yirren137@gmail.com)"

print_release() {
    echo "$RELEASE $AUTHOR"
}

print_usage() {
        echo ""
        echo "$PROGNAME $RELEASE - Statestored status check script for Nagios"
        echo ""
        echo "Usage: check_statestored_status.sh"
        echo ""
        echo "  -H  the host(default:http://10.19.248.19:25010/jsonmetrics?json)"
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
        echo "This plugin will check statestored status"
        echo ""
        exit 0
}

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
            CHECK_URL="http://${host}/jsonmetrics?json"
            ;;
	-l )
            shift
            NUMBER_OF_IMPALAD=$1
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

        CURL_RETURN=`$CURL --insecure -XGET -m 5 -s -w "#HTTPSTATUS:%{http_code}" $CHECK_URL`
        HTTP_STATUS=${CURL_RETURN#*HTTPSTATUS:}

                if [ "$HTTP_STATUS" != "200" ];then
                #       sleep 5  
            CURL_RETURN=`$CURL --insecure -XGET -m 5 -s -w "#HTTPSTATUS:%{http_code}" $CHECK_URL`
                HTTP_STATUS=${CURL_RETURN#*HTTPSTATUS:}
                fi

                JSON_SCRIPT=${CURL_RETURN%#HTTPSTATUS:*}
                #echo $JSON_SCRIPT
                LIVE_BACKENDS=`echo $JSON_SCRIPT | grep -o '"statestore.live-backends": [0-9]*'|grep -o '[0-9]*'`
                echo $[$LIVE_BACKENDS+1]
                echo $[$NUMBER_OF_IMPALAD + 1]
                if [ "$HTTP_STATUS" = "200" ];then
                      if [ "$LIVE_BACKENDS" = "$[$NUMBER_OF_IMPALAD + 1]" ];then
                        echo "OK - impala cluster status is ok"
                        exit $STATE_OK
                      fi
                      if [ $LIVE_BACKENDS -lt "$[$NUMBER_OF_IMPALAD + 1]" ] && [ $LIVE_BACKENDS -gt 1 ];then
                        echo "WARNING - some impalad lost connection"
                        exit $STATE_WARNING
                      else echo "CRITICAL - none of impalad is on"
                        exit $STATE_CRITICAL
                      fi
                      
                else
            echo "CRITICAL - HTTP_RESPONSE status code is $HTTP_STATUS"
            exit $STATE_CRITICAL
        fi
                                                                                                       115,1         Bot

