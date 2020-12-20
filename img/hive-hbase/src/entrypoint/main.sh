#!/bin/bash
echo "--------------hd-hive-base-------------------"

# 写入配置
echo "write $HIVE_HOME/conf/hive-site.xml"
env2conf.sh -e HIVE_SITE -t xml -c $HIVE_HOME/conf/hive-site.xml \
            --xmlTemplate='<property><name>@key@</name><value>@value@</value></property>' \
            --xmlAppendTo=configuration


# 0. 必须先启动mysql
# 1. 初始化
schematool -dbType mysql -initSchema