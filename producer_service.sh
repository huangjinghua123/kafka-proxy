#!/bin/bash

#ntpdate 0.centos.pool.ntp.org
APP_PATH=/home/www/
APP_NAME=kafka-producer-service-1.0.0.jar
#判断参数是否存在
if [ x"$2" = x ]; then
  echo "Example:sh producer_service.sh [start|stop|restart|status] [tw_pika_biz|tw_pika_log|tw_pika_public|tw_pika_sci]"
  exit 1
fi
ACTIVE=$2

case $1 in
start)
  mkdir -p ${HOME}/logs/producer
  java -jar ${APP_PATH}${APP_NAME} -xmx=6g -xms=6g -xmn=2g --XX:MetaspaceSize=1g --XX:MaxMetaspaceSize=1g --spring.profiles.active=${ACTIVE} &
  echo ${APP_NAME}:$2 start!
  ;;
stop)
  P_ID=$(ps -ef | grep -w "${APP_NAME}" | grep -v "grep" | awk '{print $2}')
  if [ "$P_ID" == "" ]; then
    echo "-------${APP_NAME} process not exists or stop success"
  else
    curl -X POST http://127.0.0.1:8080/actuator/shutdown
    echo "-------${APP_NAME} process pid is : $P_ID"
    echo "-------begin kill ${APP_NAME} process, pid is : $P_ID"
    kill -15 $P_ID
  fi
  echo ${APP_NAME} stop!
  ;;
restart)
  bash "$0" stop ${ACTIVE}
  echo project is restarting
  sleep 10
  bash "$0" start ${ACTIVE}
  ;;
status)
  ps -aux | grep ${APP_NAME} | grep -v 'grep'
  ;;
*)
  echo "Example:sh producer_service.sh [start|stop|restart|status] test205"
  ;;
esac
