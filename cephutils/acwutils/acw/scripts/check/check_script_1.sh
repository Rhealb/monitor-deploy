
# writen by WangShengtao

# source /etc/script-exporter/scripts/func_utils.sh
# source ~/GO_Workspace/gopath/src/prometheus/configs-on-ceph/yancheng/prometheus/script-exporter/scripts/func_utils.sh
# parentDir=`dirname $0`
source ./func_utils.sh
AUTHOR="(c) 2017 WangShengtao (stwang.casd@gmail.com)"
RELEASE="Revision 0.1"

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

# Paths to commands used in this script.
CURL="/usr/bin/curl"

# Plugin variable description
PROGNAME=""


SERVICENAME='""'
USERNAME='""'
PASSWD='""'
IP='""'
PORT='""'
ISHTTPS=0
GETDATAMETHOD="curl"
HEADER='""'
RESTFULAPI='""'
DATA='""'
PROXY='""'
CURLURL='""'
TIMEOUT=5
CHECKHTTPRESP=1
CHECKJSONFEILD=0
OKJSONFIELD='""'
WARNINGJSONFIELD='""'
CRITICALJSONFIELD='""'


# Parse parameters
while [ $# -gt 0 ]; do
    case "$1" in
        -servicename )
            shift
            SERVICENAME=${1}
            PROGNAME="check_${1}_status"
            ;;
        -username )
            shift
            USERNAME=${1}
            ;;
        -password )
            shift
            PASSWD=${1}
            ;;
        -IP )
            shift
            IP=${1}
            ;;
        -PORT )
            shift
            PORT=${1}
            ;;
        -ishttps )
            shift
            ISHTTPS=${1}
            ;;    
        -getdatamethod )
            shift
            GETDATAMETHOD=${1}
            ;;
        -restfulapi )
            shift
            RESTFULAPI=${1}
            ;;
        -timeout )
            shift
            TIMEOUT=${1}
            ;;
        -header )
            shift
            HEADER=${1}
            ;;
        -proxy )
            shift
            PROXY=${1}
            ;;
        -curlurl )
            shift
            CURLURL=${1}
            # echo ${CURLURL}
            ;;
        -checkhttpresp )
            shift
            CHECKHTTPRESP=${1}
            ;;
        -checkjsonfield )
            shift
            CHECKJSONFIELD=${1}
            ;;
        -OK  )
            shift
            OKJSONFIELD=${1}
            ;;
        -WARNING  )
            shift
            WARNINGJSONFIELD=${1}
            ;;
        -CRITICAL  )
            shift
            CRITICALJSONFIELD=${1}
            ;;
        -curlpostdata )
            shift
            DATA=${1}
            ;;
        -h | --help )
            print_help
            exit $STATE_OK
            ;;
        -v | --version)
            print_release
            exit $STATE_OK
            ;;
        *)
            echo "Unknown argument: $1"
            print_usage
            exit $STATE_UNKNOWN
            ;;
    esac
shift
done


# the procedure to check the status of the relative service
case "${GETDATAMETHOD}" in
    curl )
        check_status_by_curl ${USERNAME} ${PASSWD} ${IP} ${PORT} ${ISHTTPS} ${RESTFULAPI} ${TIMEOUT} "${HEADER}" "${DATA}" ${PROXY} ${CURLURL} ${CHECKHTTPRESP} ${CHECKJSONFIELD} "${OKJSONFIELD}" "${WARNINGJSONFIELD}" "${CRITICALJSONFIELD}"
        ;;
    nc )
        check_status_by_nc ${IP} ${PORT} ${TIMEOUT} ${CURLURL}
        ;;
    ldapsearch )
        check_status_by_ldapsearch ${IP} ${PORT} ${TIMEOUT}
        ;;
esac

