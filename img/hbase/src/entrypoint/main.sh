#!/bin/bash

echo '----------hbase-------------'

# 写入配置
echo "write hbase-site.xml"
env2conf.sh -e HB_SITE -t xml -c $HBASE_HOME/conf/hbase-site.xml \
            --xmlTemplate='<property><name>@key@</name><value>@value@</value></property>' \
            --xmlAppendTo=configuration

# 写入 regionserver
echo '...write regionservers...'

regionservers=$HB_regionservers
regionservers=(${regionservers//,/ })

> $HBASE_HOME/conf/regionservers
for regionserver in ${regionservers[@]}
do
    # 通过HostName从环境变量中获取对应的IP
    echo "$regionserver" >> $HBASE_HOME/conf/regionservers
done
