#!/bin/bash

CMD_ROOT="$(cd `dirname $0`;pwd)/.."
WORK_DIR="$CMD_ROOT/resource"
IMG_DIR="$CMD_ROOT/img"

function usage()
{
    cat << USAGE >&1
Usage:
    build.sh [-f imgListFilePath] [-i imgID]

Build image by imgageID list file or imageID.
conf/imglist is used by default

Options:
    -f imgListFilePath          read list of imageID from <imgListFilePath> and build every image
    -i imageID                  build image by imageID

USAGE
}

# 按照imgid编译镜像
# $1 imgID
function buildImage(){
    # 拷贝的内容
    # entrypoint
    # add
    # DockerFile

    local imgID="$1"

    # 1. 拷贝与编译相关的内容
    if [ ! -d "$IMG_DIR/$imgID" ];then
        echo "buid.sh: No such directory: $IMG_DIR/$imgID"
        exit 2
    fi

    if [ ! -f "$IMG_DIR/$imgID/Dockerfile" ];then
        echo "buid.sh: No Dockerfile: $IMG_DIR/$imgID/Dockerfile"
        exit 2
    else
        cp "$IMG_DIR/$imgID/Dockerfile" "$WORK_DIR"
    fi


    if [ -d "$IMG_DIR/$imgID/entrypoint" ];then
        cp -r "$IMG_DIR/$imgID/entrypoint" "$WORK_DIR"
    fi

    if [ -d "$IMG_DIR/$imgID/add" ];then
        cp -r "$IMG_DIR/$imgID/add" "$WORK_DIR"
    fi

    # 2. 解析 Dockerfile，并生成 .dockerignore
    echo '*' > "$WORK_DIR/.dockerignore"
    echo '!entrypoint' >> "$WORK_DIR/.dockerignore"
    echo '!add' >> "$WORK_DIR/.dockerignore"
    echo '!DockerFile' >> "$WORK_DIR/.dockerignore"

    # linux
    # envs=( $(sed -nE 's/^\s+ENV\s+(.*)/\1/ip' "$WORK_DIR/Dockerfile") )
    # ignores=( $(sed -nE 's/^\s=(ADD|COPY)\s+(.*)\s+.*/\2/ip' "$WORK_DIR/Dockerfile") )
    # macos
    # 抽取所有 ENV
    envs=( $(grep -iE "^\s*ENV" "$WORK_DIR/Dockerfile"| awk '{print $2, $3}') )
    # 抽取所有 ADD、COPY 指令中的本地目录（第一个参数）
    ignores=( $(grep -iE "^\s*(COPY|ADD)" "$WORK_DIR/Dockerfile"| awk '{print $2}') )
    
    # 通过 eval 将 所有 ENV 转换为当前shell中的变量
    for (( i=0; i<${#envs[@]}; i++));do
        # skip $PATH
        if [ "${envs[$i]}" != "PATH" -a "${envs[$i]}" != "path" ];then
            eval ${envs[$i]}='"${envs[$i+1]}"'
        fi
        i=$[$i+1]
    done

    # 通过 eval 转换 $ignoreName 中在当前shell内可能存在的环境变量
    for ignoreName in ${ignores[@]}; do
        eval "echo !$ignoreName" >> "$WORK_DIR/.dockerignore"
    done

    # 3. 编译镜像
    docker build -t "$imgID" "$WORK_DIR"
    local buildResultCode=$?

    # 4. 删除拷贝的所有资源
    rm -f   "$WORK_DIR/Dockerfile"
    rm -rf  "$WORK_DIR/entrypoint"
    rm -rf  "$WORK_DIR/add"
    rm -rf  "$WORK_DIR/.dockerignore"

    # 5. 检查编译是否成功
    if [ $buildResultCode -ne 0 ];then
        echo "\033[31mbuid.sh: $imgID build failed \033[0m"
        exit 3
    fi
}

function echoerr() {
    echo "$@" 1>&2
}


########################### main ###########################
# echo "aaa"
# if [ $# -eq 0 ];then
#     usage
#     exit 2
# fi

# 1. get option
imgListFilePath=""
imgID=""
while [ $# -gt 0 ]
do
    case "$1" in
        # -f imgListFilePath
        -f)
            imgListFilePath="$2"
            if [ -z $imgListFilePath ]; then
                echoerr "build.sh error: -f is empty"
                exit 1
            fi
            break
        ;;
        # -n imgID
        -i)
            imgID="$2"
            if [ -z $imgID ]; then
                echoerr "build.sh error: -i is empty"
                exit 1
            fi
            break
        ;;
        # other
        --help)
            usage
            exit 0
        ;;
        *)
            echoerr "build.sh error: Unknown argument: $1"
            usage
            exit 1
        ;;
    esac

done

# 2. check paramter and get imgList
imgList=()

if [ "$imgID" != "" ];then
    imgList=( "$imgID" )
else
    imgListFilePath=${imgListFilePath:-conf/imglist}

    if [ ! -f "$imgListFilePath" ]; then
        echo "build.sh: No such file: $imgListFilePath"
        exit 1
    fi

    # IFS_BK=$IFS
    # IFS=$(echo -en "\n\b")
    imgList=( $(cat "$imgListFilePath") )
    # IFS=$IFS_BK

    if [ ${#imgList[@]} -eq 0 ];then
        echo "build.sh: $imgListFilePath, image list is empty"
        exit 1
    fi
fi

# 3. build
for id in "${imgList[@]}"; do
    # echo "xxx$id"
    buildImage "$id"
done



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

