#!/bin/bash
#spark config
spark_url=("10.19.248.16:48080" "10.19.248.17:48080" "10.19.248.18:48080")
spark_worker_count=3
spark_master_count=1
spark_slave_count=2

spark_worker_instance=0
spark_master_instance=0
spark_slave_instance=0

while getopts ":H:w:" optname
do
	case "$optname" in
	  "H")
		hosts=$OPTARG
		;;
	  "w")
		spark_worker_count=$OPTARG
		;;
	  "?")
		echo "Unknown option"
	
		;;
	  ":")
		echo "No args"
		;;
	esac
done

if [[ $hosts && -n $hosts ]]
then
 	export IFS=","
	spark_url=($hosts)
	urlLen=${#spark_url[*]}
	spark_slave_count=`expr $urlLen - 1`
fi

function funCheck(){
        isStandy=$1
        isAlive=$2
        if [ $isStandy == 1 ]
        then
                val=`expr $spark_slave_instance + 1`
                spark_slave_instance=$val
        fi
        if [ $isAlive -ge 1 ]
        then
                val=`expr $spark_master_instance + 1`
                spark_master_instance=$val
                val=`expr $isAlive - 1 + $spark_worker_instance`
                spark_worker_instance=$val
        fi
}

export IFS=$'\n'
for url in ${spark_url[*]}
do
	response=`curl -m 6 -sL $url`
	standbys=(`echo "$response" | grep -c 'STANDBY'`)
	alives=(`echo "$response" | grep -c 'ALIVE'`)
	funCheck $standbys $alives
done

if [[ $spark_master_instance == $spark_master_count && $spark_slave_instance == $spark_slave_count && $spark_worker_instance == $spark_worker_count ]]
then
	exit 0
fi

if [[ $spark_master_instance == 0 || $spark_worker_instance == 0 ]]
then
	exit 2
fi

exit 1
