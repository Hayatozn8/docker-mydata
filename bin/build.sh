#!/bin/bash
IMG_PATH="$(cd `dirname $0`;pwd)/../img"
docker build -t env-common      $IMG_PATH/env-common
docker build -t env-jdk8        $IMG_PATH/env-jdk8
docker build -t env-ssh         $IMG_PATH/env-ssh
docker build -t env-zknode      $IMG_PATH/env-zknode
docker build -t env-hanode      $IMG_PATH/env-hanode
# docker build -t hive-base       $IMG_PATH/hive/base
# docker build -t hd-hive-spark   $IMG_PATH/hdspark/hd-hive-spark
#docker build -t hd-hive-pyspark $IMG_PATH/hdspark/pyspark
# docker build -t hdnginx         $IMG_PATH/hdnginx