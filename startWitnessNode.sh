#!/bin/bash
APP="java-tron-1.0.0"
JAR_NAME="$APP.zip"
MAX_STOP_TIME=60
SRKEY=$1
FullNode="FullNode"
Program="program.FullNode"

checkpid() {
 pid=`ps ux | grep $Program |grep -v grep | awk '{print $2}'`
 return $pid
}

stopService() {
  count=1
  while [ $count -le $MAX_STOP_TIME ]; do
    checkpid
    if [ $pid ]; then
       kill -15 $pid
       sleep 1
    else
       echo "java-tron stop"
       return
    fi
    count=$[$count+1]
    if [ $count -eq $MAX_STOP_TIME ]; then
      kill -9 $pid
      sleep 1
    fi
  done
}

startService() {
 echo `date` >> start.log
 total=`cat /proc/meminfo  |grep MemTotal |awk -F ' ' '{print $2}'`
 xmx=`echo "$total/1024/1024*0.8" | bc |awk -F. '{print $1"g"}'`
 logtime=`date +%Y-%m-%d_%H-%M-%S`
 unzip -o $JAR_NAME > /dev/null
 if [ "$?" != "0" ]; then
    echo "unzip failed, check unzip cmd is installed or not"
    return
 fi
 nohup $APP/bin/$FullNode  -w --private-key $SRKEY -c config.conf  >> start.log 2>&1 &

 pid=`ps ux |grep $Program |grep -v grep |awk '{print $2}'`
 echo "start java-tron with pid $pid on $HOSTNAME"
}

stopService
startService
