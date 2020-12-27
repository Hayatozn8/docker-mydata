#!/bin/bash
echo "--------------base-hive--------------------"

# 写入配置
echo "write $HIVE_HOME/conf/hive-site.xml"
env2conf.sh -e HIVE_SITE -t xml -c $HIVE_HOME/conf/hive-site.xml \
            --xmlTemplate='<property><name>@key@</name><value>@value@</value></property>' \
            --xmlAppendTo=configuration


# 初始化mysql
# 1: failed, 0: successed
initCmdStatus=1

waitCount=4
while [ $waitCount -gt 0 ];do
    schematool -dbType mysql -initSchema
    if [ $? -eq 0 ];then
        initCmdStatus=0
        break
    else
        sleep 5
        waitCount=$[$waitCount-1]
    fi
done

if [ $initCmdStatus -eq 0 ];then
    echo '----------------- schema inited -----------------'
else
    echo '----------------- schema can not init -----------------'
fi
