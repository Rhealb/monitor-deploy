
while [ 1 ]; do
    nc -w 5 -zv localhost 8092
    result=$?

    if [ "${result}" != "0" ]; then
        pid_frontend=$(ps -aux | grep '/opt/prometheus-1.5.2.linux-amd64/prometheus' | grep -v grep | awk '{print $2}')
        kill -9 ${pid_frontend}
    fi

    sleep 10
done