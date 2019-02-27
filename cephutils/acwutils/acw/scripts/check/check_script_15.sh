 # Written by wst

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

SH_MAX_LIVE_DATANODES=8
MAX_LIVE_DATANODES=${SH_MAX_LIVE_DATANODES}

# Paths to commands used in this script.
CURL="/usr/bin/curl"
CHECK_URL[0]="http://10.38.240.29:28088/jmx"
CHECK_URL[1]="http://10.38.240.30:28088/jmx"
CHECK_HDFS="RM cluster"
FLAG="LF"
MAX_LIVE_NODEMANAGERS=3

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
        echo "$PROGNAME $RELEASE - RM cluster status check script for Nagios"
        echo ""
        echo "Usage: check_rm_status.sh"
        echo ""
        echo "  -H1 the host1 -H2 the host2"
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
        -H1 | --host1)
            shift
            CHECK_URL[0]="http://${1}/jmx"
            ;;
        -H2 | --host2)
            shift
            CHECK_URL[1]="http://${1}/jmx"
            ;;
        -l )
            shift
            MAX_LIVE_NODEMANAGERS=${1}
            ;;
        -F )
            shift
            FLAG=${1}
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

        for ((num=0;num<2;num++))
        do
        (
            filename="check_${FLAG}_rm_tempfile_${num}"
            `$CURL --insecure -m 17 -s -w "#HTTPSTATUS:%{http_code}" ${CHECK_URL[${num}]} > ${filename}`
        )&
        done
        wait

        filename="check_${FLAG}_rm_tempfile_0"
        CURL_RETURN_1=$(cat ${filename})
        #echo ${CURL_RETURN_1}
        
        HTTP_STATUS_1=$(echo ${CURL_RETURN_1} | awk -F"#HTTPSTATUS:" '{print $2}')
        JSON_SCRIPT_1=${CURL_RETURN_1%#HTTPSTATUS:*}
        #echo ${HTTP_STATUS_1}
        #echo ${JSON_SCRIPT_1}
        filename="check_${FLAG}_rm_tempfile_1"
        CURL_RETURN_2=$(cat ${filename})
        #echo ${CURL_RETURN_2}
        HTTP_STATUS_2=$(echo ${CURL_RETURN_2} | awk -F"#HTTPSTATUS:" '{print $2}')
        JSON_SCRIPT_2=${CURL_RETURN_2%#HTTPSTATUS:*}
        #echo ${JSON_SCRIPT_2}       
 
        state_1=`echo $JSON_SCRIPT_1 | grep -o "This is standby RM"`
        num_Live_NodeManager_1=`echo $JSON_SCRIPT_1 | grep -o '"NumActiveNMs" : [0-9]*' | grep -o '[0-9]*'`
        # echo ${state_1}
        # echo ${num_Live_NodeManager_1}
        num_Live_NodeManager_2=`echo $JSON_SCRIPT_2 | grep -o '"NumActiveNMs" : [0-9]*' | grep -o '[0-9]*'`
        state_2=`echo $JSON_SCRIPT_2 | grep -o "This is standby RM"`
        # echo ${state_2}
        # echo ${num_Live_NodeManager_2}

        if [ "${HTTP_STATUS_1}" = "200" -a "${HTTP_STATUS_2}" = "200" ];then
            if [ "${state_1}" = "This is standby RM" ];then
                if [ ${num_Live_NodeManager_2} = ${MAX_LIVE_NODEMANAGERS} ];then
                        echo "OK - ${CHECK_HDFS} status is OK"
                        exit $STATE_OK
                elif [ ${num_Live_NodeManager_2} -gt 0];then
                    echo "WARNING - ${CHECK_HDFS} status is WARNING!"
                    exit $STATE_WARNING
                else 
                    echo "CRITICAL - ${CHECK_HDFS} status is CRITICAL!"
                    exit $STATE_CRITICAL
                fi
            elif [ "${state_2}" = "This is standby RM" ];then
                 if [ ${num_Live_NodeManager_1} = ${MAX_LIVE_NODEMANAGERS} ];then
                        echo "OK - ${CHECK_HDFS} status is OK"
                        exit $STATE_OK
                elif [ ${num_Live_NodeManager_1} -gt 0];then
                    echo "WARNING - ${CHECK_HDFS} status is WARNING!"
                    exit $STATE_WARNING
                else
                    echo "CRITICAL - ${CHECK_HDFS} status is CRITICAL!"
                    exit $STATE_CRITICAL
                fi
              else
                echo "CRITICAL - ${CHECK_HDFS} status is CRITICAL!"
                exit $STATE_CRITICAL
            fi  
        else
            echo "CRITICAL - HTTP_STATUS status is wrong!"
            exit $STATE_CRITICAL
        fi      
