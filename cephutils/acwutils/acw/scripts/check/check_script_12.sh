STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

# Plugin variable description
PROGNAME=$(basename $0)
RELEASE="Revision 0.1"
AUTHOR="(c) 2017 WeiZe (ze.wei1989@gmail.com)"

# Functions plugin usage
print_release() {
    echo "$RELEASE $AUTHOR"
}

print_usage() {
    echo ""
    echo "$PROGNAME $RELEASE - mongo replica set status checker"
    echo ""
    echo "Usage: check_mongo_rs_status.sh -H hosts1,hosts2,hosts3……"
    echo ""
    echo "  -H  the mongo servers(example:\"mongo1.monitor-essential-service:27017,mongo2.monitor-essential-service:27017,mongo3.monitor-essential-service:27017\")"
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
    echo "This plugin will check apiserver status"
    echo ""
    exit 0
}

if [ $# -eq 0 ];
then
  print_usage
  exit $STATE_UNKNOWN
fi

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
    -H | --hosts)
        shift
        MONGO_HOSTS=(${1//,/ })
        ;;
    *)
    echo "Unknown argument: $1"
        print_usage
        exit $STATE_UNKNOWN
        ;;
  esac
shift
done

countOffline=0
countPrimary=0
countSecondary=0
countOther=0
expectedSecondary=${#MONGO_HOSTS[@]}
let expectedSecondary--
for host in ${MONGO_HOSTS[@]}
do
  express="rs.status()"
  result=$(timeout 4 mongo --host ${host} --eval "$express")
  exitCode=$?
  if [ $exitCode != 0  ];then
    let countOffline++
    echo "$host -1"
  else
    repliState=$(echo $result | grep -oP "(?<=\"myState\" : )[0-9]*")
    if [ "$repliState" == "" ];then
        repliState=$(echo $result | grep -oP "(?<=\"state\" : )[0-9]*")
    fi
    if [ "$repliState" == "" ];then
        repliState=-1
    fi
    echo "$host $repliState"
    if [ $repliState == 1 ];then
      let countPrimary++
    elif [[ $repliState == 2 ]]; then
      let countSecondary++
    else
      let countOther++
    fi
  fi
done
if [ $countPrimary -lt 1 ];then
  exit $STATE_CRITICAL
elif [ $countSecondary -lt 1 ]; then
  exit $STATE_CRITICAL
elif [ $countSecondary -lt $expectedSecondary ]; then
  exit $STATE_WARNING
else
  exit $STATE_OK
fi