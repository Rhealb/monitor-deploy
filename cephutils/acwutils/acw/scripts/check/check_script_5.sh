# Written by Wei Ze

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

# Paths to commands used in this script.
CURL="/usr/bin/curl"

# Plugin variable description
PROGNAME=$(basename $0)
RELEASE="Revision 0.1"
AUTHOR="(c) 2018 Wang Shengtao (stwang.casd@gmail.com)"

# Functions plugin usage
print_release() {
   echo "$RELEASE $AUTHOR"
}

print_usage() {
       echo ""
       echo "$PROGNAME $RELEASE - mongo status check script for Nagios"
       echo ""
       echo "Usage: check_hbase_status.sh"
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
       echo "This plugin will check mongo status"
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
           host=${1}
           ;;
       -P | --port)
           shift
           port=${1}
           ;;
       *)

     echo "Unknown argument: $1"
           print_usage
           exit $STATE_UNKNOWN
           ;;
       esac
shift
done

result=$(timeout 4 mongo --host ${host}:${port} --eval "db.stats()")
exitCode=$?
if [ $exitCode != 0  ];then
  exit $STATE_CRITICAL
else
  state=$(echo $result | grep -oP "(?<=\"ok\" : )[0-9]*")
  if [ "$state" == "" ];then
      state=-1
  fi
  if [ $state == 1 ];then
    exit $STATE_OK
  else
    exit $STATE_CRITICAL
  fi
fi
