
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

function print_release() {
    echo "$RELEASE $AUTHOR"
}


function print_usage() {
    echo ""
    echo "$PROGNAME $RELEASE - ${SERVICENAME} status check script for Enncloud"
    echo ""
    echo "Usage: "
    echo ""
    echo "  -u  the url(default:https://10.19.248.19:443)"
    echo "  -n  username to login(default:admin)"
    echo "  -p  passwd to login(default:admin)"
    echo "  -v  check the version"
    echo ""
    echo "Usage: $PROGNAME"
    echo ""
}


function print_help() {
    print_usage

    echo ""
    echo "This program will check ${SERVICENAME} status!"
    echo ""
}


function parse_json(){
	json_script=${1}
	jsonfield=${2}
    jsonfield=${jsonfield/'\'/""}

	num=`echo ${json_script} | grep -o "${jsonfield}" | wc -l`

	if [ ${num} -ge 1 ]; then
		return 1
	fi

	return 0
}


function check_status_by_nc(){
    IP=${1}
    PORT=${2}
    TIMEOUT=${3}
    CURLURL=${4}

    if [ "${CURLURL}" != '""' ]; then
    	nc -w ${TIMEOUT} -x ${IP}:${PORT} ${CURLURL} 80
    else
    	nc -w ${TIMEOUT} -zv ${IP} ${PORT}
    fi

    RESULT=$?

    case ${RESULT} in
        0 )
            shift
            echo "OK, The status is OK"
            exit ${STATE_OK}
            ;;
        * )
            shift
            echo "CRITICAL, The status is CRITICAL"
            exit ${STATE_CRITICAL}
            ;;
    esac
}


function check_status_by_ldapsearch(){
    IP=${1}
    PORT=${2}
    TIMEOUT=${3}

    RESULT=`ldapsearch -h ${IP} -p ${PORT} -l ${TIMEOUT} -x -b "" | grep numResponse | wc -l`

    case ${RESULT} in
        1 )
            shift
            echo "OK, the status is OK"
            exit ${STATE_OK}
            ;;
        * )
            shift
            echo "Critical, the status is CRITICAL"
            exit ${STATE_CRITICAL}
            ;;
    esac
}


function check_status_by_curl(){
	username=${1}
	passwd=${2}
	IP=${3}
	PORT=${4}
	ISHTTPS=${5}
	RESTFULAPI=${6}
	TIMEOUT=${7}
	HEADER=${8}
	POSTDATA=${9}
	CURLSERVICENAME=${10}
	CURLURL=${11}
	CHECKHTTPREPO=${12}
	CHECKJSONFIELD=${13}
	OKJSONFIELD=${14}
	WARNINGJSONFIELD=${15}
	CRITICALJSONFIELD=${16}

	if [ "${RESTFULAPI}" = '""' ]; then
		RESTFULAPI=""
	fi

	# generate username_passwd_para
	username_passwd_para=""

	if [ "${username}" != '""' ];then 
		username_passwd_para="-u ${username}"

		if [ "${passwd}" != '""' ]; then
			username_passwd_para="${username_passwd_para}:${passwd}"
		fi

		#echo ${username_passwd_para}
	fi

	# generate head_para
	header_para=""

	if [ "${HEADER}" != '""' ];then 
		header_para="-H ${HEADER}"
	fi

	# generate postdata_para
	postdata_para=""

	if [ "${POSTDATA}" != '""' ];then 
		postdata_para="-d ${POSTDATA}"
	fi	

	# generate httpcode_para
	httpcode_para=""

	if [ ${CHECKHTTPREPO} == 1 ]; then
		httpcode_para="-w "#HTTPSTATUS:%{http_code}""
	fi

	# generate CHECK_URL and proxy_para
	proxy_para=""

	if [ "${CURLURL}" != '""' ];then
		CHECK_URL=${CURLURL}

		if [ "${CURLSERVICENAME}" != '""' ]; then
			proxy_para="--${CURLSERVICENAME} ${IP}:${PORT}"
			CURL_RETURN=`curl --insecure -m ${TIMEOUT} ${proxy_para} ${header_para} ${postdata_para} ${httpcode_para} -L $CHECK_URL`
		else
			proxy_para="-x ${IP}:${PORT}"
			CURL_RETURN=`curl --insecure -m ${TIMEOUT} ${proxy_para} ${header_para} ${postdata_para} ${httpcode_para} -L $CHECK_URL`
		fi
	else
		if [ ${ISHTTPS} == 1 ]; then
			CHECK_URL="https://${IP}:${PORT}${RESTFULAPI}"

			CURL_RETURN=`curl --insecure -m ${TIMEOUT} ${username_passwd_para} ${header_para} ${postdata_para} ${httpcode_para} -L $CHECK_URL`
		else
			CHECK_URL="http://${IP}:${PORT}${RESTFULAPI}"
			#curl_request="${username_passwd_para} ${header_para} ${postdata_para} \"#HTTPSTATUS:%{http_code}\" $CHECK_URL"

			CURL_RETURN=`curl -m ${TIMEOUT} ${username_passwd_para} ${header_para} ${postdata_para} ${httpcode_para} -L $CHECK_URL`
		fi
	fi

	#echo ${CURL_RETURN}

	HTTP_STATUS=$(echo ${CURL_RETURN} | awk -F"#HTTPSTATUS:" '{print $2}')

	if [ ${CHECKJSONFIELD} == 1 ];then
		JSON_SCRIPT=${CURL_RETURN%#HTTPSTATUS:*}

		OK_STATUS=0

		if [ ${HTTP_STATUS} == 200 -o ${HTTP_STATUS} == 201 ]; then
			parse_json "${JSON_SCRIPT}" "${OKJSONFIELD}"
			OK_STATUS=$?

			if [ "${OK_STATUS}" = "1" ];then
				echo "OK - The SERVICE_STATUS is OK !"
                exit $STATE_OK
			fi

			if [ "${CRITICALJSONFIELD}" != '""' ]; then
				CRITICAL_STATUS=0
				parse_json "${JSON_SCRIPT}" "${CRITICALJSONFEILD}"
				CRITICAL_STATUS=$?

				if [ "${CRITICAL_STATUS}" = "1" ];then
					echo "CRITICAL - The SERVICE_STATUS is CRITICAL !"
                	exit $STATE_CRITICAL
				fi
			fi

			if [ "${WARNINGJSONFIELD}" != '""' ]; then
				WARNING_STATUS=0
				parse_json "${JSON_SCRIPT}" "${WARNINGJSONFIELD}"
				WARNING_STATUS=$?

				if [ "${WARNING_STATUS}" = "1" ];then
					echo "WARNING - The SERVICE_STATUS is WARNING !"

                	exit $STATE_WARNING
				fi
			fi
				echo "CRITICAL - The SERVICE_STATUS is CRITICAL !"
                exit $STATE_CRITICAL
         else
         	echo "CRITICAL - The HTTP_STATUS is ${HTTP_STATUS} !"
         	exit $STATE_CRITICAL
		fi
	else
		case "${HTTP_STATUS}" in
			200 )
				echo "OK - The HTTP_STATUS is 200"
                exit $STATE_OK
				;;

			* )
				echo "CRITICAL - The HTTP_STATUS is ${HTTP_STATUS} !"
                exit $STATE_CRITICAL
				;;
		esac
	fi
}
