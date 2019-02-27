 # Written by renyi

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

CLUSTER_NAME="yc"
IP=10.38.240.28
PORT=3306

check_feild="mysql_native_password"

# Plugin variable description
PROGNAME=$(basename $0)
RELEASE="Revision 0.1"

# Functions plugin usage
print_release() {
    echo "$RELEASE $AUTHOR"
}

print_usage() {
    echo ""
    echo "$PROGNAME $RELEASE - MySQL status check script for xh"
    echo ""
    echo "Usage: check_kafka_status.sh"
    echo ""
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
    echo "This plugin will check MySQL status"
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
        -IP | --host)
            shift
            IP=$1
            ;;
        -PORT )
            shift
            PORT=${1}
            ;;
        -Cluster_name )
            shift
            CLUSTER_NAME=${1}
            ;;        
        *)
            echo "Unknown argument: $1"
            print_usage
            exit $STATE_UNKNOWN
            ;;
        esac
shift
done

`nc -w 10 ${IP} ${PORT} > check_${CLUSTER_NAME}_mysql_tempfile`

RETURN=$(cat check_${CLUSTER_NAME}_mysql_tempfile)

NUM=$(echo ${RETURN} | grep -o 'mysql_native_password' | wc -l)

if [ ${NUM} == 1 ];then
    echo "OK - ${CHECK_KAFKA} status is OK!" 
    exit $STATE_OK
  else
    echo "CRITICAL - ${CHECK_KAFKA} status is CRITICAL!"
    exit $STATE_CRITICAL
fi
