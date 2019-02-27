
IP='""'

while [ $# -gt 0 ]; do
    case "$1" in
        -ip )
            shift
            IP=${1}
            ;;
    esac
shift
done

fping ${IP}

if [ $? == 0 ]; then
	exit 0
else
	exit 2
fi