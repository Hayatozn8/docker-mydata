#!/bin/bash
echo "--------------flume-------------------"

# 将 FLUME 开头的环境变量转换为配置并写入文件
env2conf.sh -e FLUME -c /flume/conf/base.conf -x "home" 


# 启动 flume
# flume-ng agent \
# -n a1 \
# -c $FLUME_HOME/conf \
# -f /flume/conf/base.conf \
# -Dflume.root.logger=INFO,console