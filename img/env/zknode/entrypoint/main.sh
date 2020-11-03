#!bin/bash
echo "--------------zknode-------------------"

# 如果未设置 $ZOO_MY_ID ，则不启动过结点并退出处理
if [ -z $ZOO_MY_ID ]; then
    exit 0
fi

echo "$ZOO_MY_ID" > /zkdata/myid

if [ -n "$ZOO_SERVERS" ]; then
    # 如果能获取到 $ZOO_SERVERS，则替换配置文件中的服务配置
    sed -i "s@server\..*=.*:.*:.*@@g" $ZOOKEEPER_HOME/conf/zoo.cfg

    serverInfoList=( $ZOO_SERVERS )
    for serverInfo in ${serverInfoList[@]}; do
        echo $serverInfo >> $ZOOKEEPER_HOME/conf/zoo.cfg
    done
else
    # 如果不能获取到 $ZOO_SERVERS，则从配置文件中抽取servers信息
    serverInfoList=( $( grep "server" myzoo.cfg ) )
fi

for serverInfo in ${serverInfoList[@]}; do
    # get serverName
    serverName=$(echo $serverInfo|sed -nr 's@server.*=(.*):.*:.*@\1@p')

    # check serverName in /etc/hosts (docker network--> skip)

    # ssh connect
    createSSHConnect.sh $serverName
done

# 启动 zk 集群/结点
zkServer.sh start