#!/bin/bash

# 拷贝的内容
# entrypoint
# add
# DockerFile

CMD_ROOT="$(cd `dirname $0`;pwd)/.."
WORK_DIR="$CMD_ROOT/resource"
IMG_DIR="$CMD_ROOT/img"
echo $WORK_DIR

conf=${1:-conf/imglist}
echo $conf

if [ ! -f "$conf" ]; then
    echo "\build.sh: No such file: $conf"
    exit 1
fi

for imgName in $(cat "$conf"); do
    # 检查镜像目录是否存在
    if [ ! -d "$IMG_DIR/$imgName" ];then
        echo "buid.sh: No such directory: $IMG_DIR/$imgName"
        exit 2
    fi

    # 检查 Dockerfile 是否存在
    if [ ! -f "$IMG_DIR/$imgName/Dockerfile" ];then
        echo "buid.sh: No Dockerfile: $IMG_DIR/$imgName/Dockerfile"
        exit 2
    fi

    # 拷贝 Dockerfile 到 WORK_DIR
    cp "$IMG_DIR/$imgName/Dockerfile" "$WORK_DIR"

    # 如果有 entrypoint 目录，则拷贝到 WORK_DIR
    if [ -d "$IMG_DIR/$imgName/entrypoint" ];then
        cp -r "$IMG_DIR/$imgName/entrypoint" "$WORK_DIR"
    fi
    
    # 如果有 add 目录，则拷贝到 WORK_DIR
    if [ -d "$IMG_DIR/$imgName/add" ];then
        cp -r "$IMG_DIR/$imgName/add" "$WORK_DIR"
    fi

    # 编译镜像
    docker build -t "$imgName" "$WORK_DIR"

    # 保存执行结果code
    buildResultCode=$?

    # 删除拷贝的所有资源
    rm -f   "$WORK_DIR/Dockerfile"
    rm -rf  "$WORK_DIR/entrypoint"
    rm -rf  "$WORK_DIR/add"

    # 检查编译是否成功
    if [ $buildResultCode -ne 0 ];then
        echo "\033[31mbuid.sh: $imgName build failed \033[0m"
        exit 3
    fi
done







# IMG_PATH="$(cd `dirname $0`;pwd)/../img"
# docker build -t env-common      $IMG_PATH/env-common
# docker build -t env-jdk8        $IMG_PATH/env-jdk8
# docker build -t env-ssh         $IMG_PATH/env-ssh
# docker build -t env-zknode      $IMG_PATH/env-zknode
# docker build -t env-hanode      $IMG_PATH/env-hanode

# # 1. read image name from config
# IFS=$(echo -en "\n\b")
# imageList=($(cat xxxx))

# # 2. first dependency check
# # TODO
# parentDependency="${imageList[0]}"
# if [ -z $(docker images | grep "$parentDependency") ]; then
#     echo "can't find the docker image: ${imageList[0]}" 1>&2
#     exit 1
# fi

# # 3. dependency check
# for ((i=1; i<)); do
# done

# # 2. build image
# for imgName in ${imgNameList[@]} do
#     docker build -t $imgName      "$IMG_PATH/$imgName"
# done

# centos:latest
# env-common
# env-jdk8
# env-ssh
# env-zknode
# env-hanode
# kafka-base
# kafka-eagle-node
# kafka-eagle-webui





# bogon:00_data-docker liujinsuo$ docker images
# REPOSITORY                  TAG                 IMAGE ID            CREATED             SIZE
# kafka-eagle-webui           latest              ac1adaeac433        8 hours ago         829MB
# kafka-eagle-node            latest              2c5bb871cc86        8 hours ago         682MB
# kafka-base                  latest              0dd9388410b7        8 hours ago         682MB
# env-hanode                  latest              6da26907eece        8 hours ago         1.63GB
# env-zknode                  latest              2ced57c0a5bc        8 hours ago         714MB
# env-ssh                     latest              69a5a9655d6f        8 hours ago         654MB
# env-jdk8                    latest              f9d37940e714        8 hours ago         591MB
# env-common                  latest              a946eb3b5344        8 hours ago         215MB
# <none>                      <none>              8c539fb0bba5        3 days ago          890MB
# docker-mac-network_proxy    latest              b0c81f1aa2e4        8 days ago          6.96MB
# hanode                      latest              3bbc21fc0d1e        2 weeks ago         1.63GB
# zknode                      latest              568d9f3e3958        2 weeks ago         713MB
# kylemanna/openvpn           latest              d5a2586f86e0        2 weeks ago         15.3MB
# env-ssh-jdk8                latest              05bc6f110709        2 weeks ago         653MB
# hd-hive-spark               latest              c23dcb654998        3 weeks ago         2.08GB
# hd-hive-base                latest              ad1791a63cb5        3 weeks ago         1.91GB
# hdnode                      latest              df76db8fa893        3 weeks ago         1.57GB
# common-env                  latest              3efc5fd1c709        3 weeks ago         215MB
# mysql                       5.7                 1b12f2e9257b        3 weeks ago         448MB
# alpine                      latest              d6e46aa2470d        3 weeks ago         5.57MB
# hd-hive-pyspark             latest              845c4751cefa        7 weeks ago         2.81GB
# hdnginx                     latest              4ef295dd5f41        7 weeks ago         133MB
# hd-hive-hdspark             latest              6f4a2914c2c1        7 weeks ago         1.36GB
# env-ssh-openjdk8            latest              7d32f06b27a3        7 weeks ago         495MB
# python                      latest              bbf31371d67d        7 weeks ago         882MB
# hdspark                     latest              0f36fc04beb8        8 weeks ago         1.08GB
# nginx                       latest              7e4d58f0e5f3        2 months ago        133MB
# centos                      latest              0d120b6ccaa8        3 months ago        215MB
# mycentos/nginx              1                   34684179dd2f        6 months ago        776MB
# alpine/git                  latest              f69fa32a7cd6        6 months ago        27.8MB
# gitcustom                   1                   f2b888b10391        7 months ago        1.16GB
# mygit/default               1                   b584737f03de        7 months ago        1.07GB
# mycentos/base               1                   ef18326304b4        7 months ago        568MB
# mycentos/dnf                1                   d597e99fc8eb        7 months ago        363MB
# mysql                       latest              9b51d9275906        8 months ago        547MB
# redis                       latest              7eed8df88d3b        8 months ago        98.2MB
# vimnet/centos               1                   835f9af1c7d8        10 months ago       459MB
# vim/centos                  0                   5157c3378202        10 months ago       359MB
# tomcat                      latest              6fa48e047721        11 months ago       507MB
# centos                      centos7             5e35e350aded        12 months ago       203MB
# twang2218/gitlab-ce-zh      latest              18da462b5ff5        2 years ago         1.61GB
# absolutapps/oracle-12c-ee   latest              ad9bdfc002e7        4 years ago         6.12GB

