 # Written by wst

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

# Paths to commands used in this script.
CURL="/usr/bin/curl"

CHECK_URL="http://10.19.248.200:30005"
CLUSTER_NAME="yc"
KAFKA_URL=(kafka1:9999 kafka2:9999 kafka3:9999 kafka4:9999 kafka5:9999)
#KAFKA_URL=(10.19.248.14:9999 10.19.248.15:9999 10.19.248.32:9999 10.19.248.33:9999 10.19.248.34:9999)

CHECK_KAFKA="kafka"
MAX_BROKER_NUM=5

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
    echo "$PROGNAME $RELEASE - Kafka status check script for xh"
    echo ""
    echo "Usage: check_kafka_status.sh"
    echo ""
    echo "  -H  the host(default:http://10.19.140.200:30005)"
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
    echo "This plugin will check kafka status"
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
            CHECK_URL="http://${host}"
            ;;
        -KAFKAURL )
            shift
            URL=${1}
            KAFKA_URL=(${URL//,/' '})
            MAX_BROKER_NUM=${#KAFKA_URL[*]}
            ;;
        -F )
            shift
            CLUSTER_NAME=${1}
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

for ((num=0; num<MAX_BROKER_NUM; ++num))
do
    {
        # echo "${num}______${num}" >> log.txt
        # start=$(date +%s.%N)  
        `$CURL -d ${KAFKA_URL[num]} --insecure -m 17 -w %{http_code} -s ${CHECK_URL} > check_${CLUSTER_NAME}_kafka_tempfile_${num}`

        # end=$(date +%s.%N)

        # start_s=$(echo $start | cut -d '.' -f 1)  
        # start_ns=$(echo $start | cut -d '.' -f 2)  
        # end_s=$(echo $end | cut -d '.' -f 1)  
        # end_ns=$(echo $end | cut -d '.' -f 2) 

        # time=$(( ( 10#$end_s - 10#$start_s ) * 1000 + ( 10#$end_ns / 1000000 - 10#$start_ns / 1000000 ) ))

        # echo "${KAFKA_URL[num]}----TIME: ${time} ms"
    }&
done
wait

ActiveControllerNum=0
OK_NUM=0
UnderReplicatedPartitionsNum=0

for ((num=0; num<MAX_BROKER_NUM; ++num))
do
    RETURN=""
    RETURN=$(cat check_${CLUSTER_NAME}_kafka_tempfile_${num})

    ActiveControllerCount=""

    if [ "${RETURN}" != "" ];then
        ActiveControllerCount=$(echo ${RETURN} | grep -o '"ActiveControllerCount",} [0-9]*\.[0-9]*' | grep -o '[0-9]*\.[0-9]*')
        UnderReplicatedPartitions=$(echo ${RETURN} | grep -o '"UnderReplicatedPartitions",} [0-9]*\.[0-9]*' | grep -o '[0-9]*\.[0-9]*')
        OfflinePartitionsCount=$(echo ${RETURN} | grep -o '"OfflinePartitionsCount",} [0-9]*\.[0-9]*' | grep -o '[0-9]*\.[0-9]*')

        if [[ ${ActiveControllerCount} = "" ]];then
            echo "${KAFKA_URL[num]} is error!"
        fi

        if [ ${ActiveControllerCount} == 1.0 ];then
            ActiveControllerNum=$[${ActiveControllerNum}+1]

            if [ ${ActiveControllerNum} -gt 1 ];then
                echo "ActiveControllerNum: ${ActiveControllerNum}"
                echo "CRITICAL - ${CHECK_KAFKA} status is CRITICAL!"
                exit $STATE_CRITICAL
            fi
        fi
            
        if [ ${OfflinePartitionsCount} == 0.0 ];then
            OK_NUM=$[${OK_NUM}+1]
        fi

        if [[ ${UnderReplicatedPartitions} != 0.0 ]];then
            UnderReplicatedPartitionsNum=$[${UnderReplicatedPartitionsNum}+1]
        fi
    fi
done

if [ ${ActiveControllerNum} == 0 ]; then
    echo "ActiveControllerNum: ${ActiveControllerNum}"
    echo "CRITICAL - ${CHECK_KAFKA} status is CRITICAL!"
    exit $STATE_CRITICAL
fi

if [ ${OK_NUM} == ${MAX_BROKER_NUM} ];then
    if [[ ${UnderReplicatedPartitionsNum} == 0 ]]; then
        echo "OK - ${CHECK_KAFKA} status is OK!"
        exit $STATE_OK
    else
        echo "Not all of the brokers are OK !"
        echo "WARNING - ${CHECK_KAFKA} status is WARNING!"
        exit $STATE_WARNING 
    fi
elif [ ${OK_NUM} -lt $[${MAX_BROKER_NUM}-2] ]; then
    echo "The number of OK broker is less than MAX_BROKER_NUM-2 !"
    echo "CRITICAL - ${CHECK_KAFKA} status is CRITICAL!"
    exit $STATE_CRITICAL
  else
    echo "Not all of the brokers are OK !"
    echo "WARNING - ${CHECK_KAFKA} status is WARNING!"
    exit $STATE_WARNING 
fi
