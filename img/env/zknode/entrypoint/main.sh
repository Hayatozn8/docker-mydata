#!/bin/bash
echo "--------------zknode-------------------"

# 如果未设置 $ZOO_MY_ID ，则按照单结点进行处理
if [ -n $ZOO_MY_ID ]; then
    echo "$ZOO_MY_ID" > /zkdata/myid
fi

# 尝试将配置写入/zkconfig
env2conf.sh ZOO $ZOOKEEPER_HOME/conf/zoo.cfg "" "" "my.id"
env2conf.sh ZOOLOG $ZOOKEEPER_HOME/conf/log4j.properties

# 与集群中的其他结点做ssh连接
serverInfoList=( $( grep -e "^server\..*" $ZOOKEEPER_HOME/conf/zoo.cfg ) )

for serverInfo in ${serverInfoList[@]}; do
    # get serverName
    serverName=$(echo $serverInfo|sed -r 's@server.*=(.*):.*:.*@\1@')

    # check serverName in /etc/hosts (docker network--> skip)

    # ssh connect
    createSSHConnect.sh $serverName
done

# 启动 zk 集群/结点
zkServer.sh start