#!/bin/bash

echo '----------hbase-------------'

# 写入配置
echo "write hbase-site.xml"
env2conf.sh -e HB_SITE -t xml -c $HBASE_HOME/conf/hbase-site.xml \
            --xmlTemplate='<property><name>@key@</name><value>@value@</value></property>' \
            --xmlAppendTo=configuration

ln -s $HADOOP_HOME/etc/hadoop/core-site.xml $HBASE_HOME/conf/core-site.xml

ln -s $HADOOP_HOME/etc/hadoop/hdfs-site.xml $HBASE_HOME/conf/hdfs-site.xml

echo '...write regionservers...'

regionservers=$HB_regionservers
regionservers=(${regionservers//,/ })

> $HBASE_HOME/conf/regionservers
for regionserver in ${regionservers[@]}
do
    # 通过HostName从环境变量中获取对应的IP
    echo "$regionserver" >> $HBASE_HOME/conf/regionservers
done
