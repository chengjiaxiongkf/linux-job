#!/bin/bash
DIR=$(
    cd "$(dirname "$0")"
    pwd
)
SERVICE_NAME=$(basename $DIR)
PID=$(pgrep -a -f $SERVICE_NAME | awk '{print $1 " "}')
JAR_NAME="app.jar"

JAVA_AGENT="-agentpath:/tmp/cdbg_java_agent.so"
#--远程debug，热部署
#JAVA_AGENT="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5503"

#--prometheus push模式
#JAVA_AGENT="-javaagent:$DIR/jmx_pmtheus/./jmx_prometheus.jar=8099:$DIR/jmx_pmtheus/config.yaml"
#AGENT_JAR=/home/api/pinpoint-agent/pinpoint-bootstrap-1.8.0-RC1.jar
#AGENT_NAME="$(echo ${SERVICE_NAME} | sed 's/zhengtyun-service-//')-$(ifconfig eth0 | grep inet | grep -v inet6 | awk '{print $2}'# | awk -F. '{print $3"."$4}')"
#AGENT_ID="$(ifconfig eth0 | grep inet | grep -v inet6 | awk '{print $2}' | awk -F. '{print $3"."$4}')-$SERVICE_PORT"

#启用G1垃圾回收器,最大停顿时间200ms
JAVA_OPTS="-Dserver.port=10000 -Dspring.profiles.active=prod -Dspring.application.name=${SERVICE_NAME} -Djava.security.egd=file:/dev/./urandom-server -Xmx512m -Xms512m -Xss512K -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

function do_start() {
    CURRPID=$(pgrep -a -f $SERVICE_NAME | awk '{print $1 " "}')
    if test -z "$CURRPID"; then
        echo "Starting $SERVICE_NAME..."
        source /etc/profile
        mkdir -p jvm/
        nohup java $JAVA_AGENT $JAVA_OPTS -jar $JAR_NAME &
        sleep 3s
        NEWPID=$(pgrep -a -f $SERVICE_NAME | awk '{print $1 " "}')
        echo "$SERVICE_NAME started, it's pid is ${NEWPID}."
    else
        echo "$SERVICE_NAME is already running, it's pid is ${CURRPID}."
    fi
}

function do_stop() {
    pgrep -a -f $SERVICE_NAME
    CURRPID=$(pgrep -a -f -n $SERVICE_NAME | awk '{print $1 " "}')
    echo "Stoping $SERVICE_NAME, it's pid is ${CURRPID}."
    #注意不能直接kill -9，会造成服务异常。以下策略先尝试使用-15，保证服务正常下线，再用-9确保服务结束。
    #即：服务有5s时间安全下线结束，超时则强制结束
    pkill -f -c -15 $SERVICE_NAME
    sleep 5s
    pkill -f -c -9 $SERVICE_NAME
    echo "$SERVICE_NAME has graceful stopped, it's pid is ${CURRPID}."
}

case $1 in
start)
    do_start
    ;;
stop)
    do_stop
    ;;
restart)
    if test -z "$PID"; then
        echo "$SERVICE_NAME is not running."
        do_start
    else
        echo "$SERVICE_NAME is already running, it's pid is ${PID}."
        echo "killing..."
        kill -9 $PID
        echo "Sleep for 5s to start"
        sleep 5
        echo "starting..."
        do_start
    fi
    ;;
status)
    if test -z "$PID"; then
        echo "$SERVICE_NAME is not running."
    else
        echo "$SERVICE_NAME is running, it's pid is ${PID}."
    fi
    ;;
*)
    echo "Usage: ${0} start|stop|restart|status"
    ;;
esac

