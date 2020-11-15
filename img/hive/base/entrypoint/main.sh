#!/bin/bash
echo "--------------hd-hive-base-------------------"

# 0. 必须先启动mysql
# 1. 初始化
schematool -dbType mysql -initSchema