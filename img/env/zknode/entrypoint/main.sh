#!bin/bash
echo "--------------zknode-------------------"

# 如果未设置 $ZOO_MY_ID ，则不启动过结点并退出处理
if [ -z $ZOO_MY_ID ]; then
    exit 0
fi

echo "$ZOO_MY_ID" > /zkdata/myid

# 尝试获取 $ZOO_SERVERS。如果能获取到，则替换配置文件中的服务配置
if [ -n "$ZOO_SERVERS" ]; then
    sed -i "s@server\..*=.*:.*:.*@@g" $ZOOKEEPER_HOME/conf/zoo.cfg
    echo $ZOO_SERVERS >> $ZOOKEEPER_HOME/conf/zoo.cfg
fi

# 启动 zk 集群/结点
zkServer.sh start