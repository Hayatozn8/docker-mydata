#!/bin/bash
sleep 10
echo "--------------azkaban----------------"

if [ -z "$AZWEB_web_resource_dir" ];then
    # 默认web server存放web文件的目录 
    export AZWEB_web_resource_dir=/opt/module/azkaban/web/web/
fi
if [ -z "$AZWEB_user_manager_xml_file" ];then
    # 用户权限管理默认类(绝对路径) 
    export AZWEB_user_manager_xml_file=/opt/module/azkaban/web/conf/azkaban-users.xml
fi
if [ -z "$AZWEB_executor_global_properties" ];then
    # global 配置文件所在位置(绝对路径) 
    export AZWEB_executor_global_properties=/opt/module/azkaban/executor/conf/global.properties
fi
if [ -z "$AZWEB_jetty_keystore" ];then
    # SSL 文件名(绝对路径) 
    export AZWEB_jetty_keystore=/opt/module/azkaban/keystore 
fi
if [ -z "$AZWEB_jetty_truststore" ];then
    # SSL 文件名(绝对路径) 
    export AZWEB_jetty_truststore=/opt/module/azkaban/keystore 
fi

env2conf.sh -e AZWEB -c /opt/module/azkaban/web/conf/azkaban.properties

if [ -z "$AZEXE_executor_global_properties" ];then
    # SSL 文件名(绝对路径) 
    export AZEXE_executor_global_properties=/opt/module/azkaban/executor/conf/global.properties
fi

env2conf.sh -e AZEXE -c /opt/module/azkaban/executor/conf/azkaban.properties

env2conf.sh -e AZUSER_ADMIN_METRICS -t xml -c /opt/module/azkaban/web/conf/azkaban-users.xml \
            --xmlTemplate='<user username="@key@" password="@value@" roles="admin,metrics"/>' \
            --xmlAppendTo=azkaban-users

sh /opt/module/azkaban/executor/bin/azkaban-executor-start.sh

sh /opt/module/azkaban/web/bin/azkaban-web-start.sh

