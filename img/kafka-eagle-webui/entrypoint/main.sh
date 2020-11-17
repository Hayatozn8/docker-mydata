#!/bin/bash
echo "--------------kafka-eagle-webui-------------------"

# 将 KE 开头的环境变量转换为配置并写入文件
env2conf.sh KE $KE_HOME/conf/system-config.properties "" "" "home" 

# 启动webui服务
# ke.sh start
# kafka-server-start.sh -daemon /kafkaConfig/server.properties