#!/bin/bash
IMG_PATH="$(cd `dirname $0`;pwd)/../img"
docker build -t kafka-base          $IMG_PATH/kafka-base
docker build -t kafka-eagle-node    $IMG_PATH/kafka-eagle-node
docker build -t kafka-eagle-webui   $IMG_PATH/kafka-eagle-webui
# docker build -t hive-base       $IMG_PATH/hive/base
# docker build -t hd-hive-spark   $IMG_PATH/hdspark/hd-hive-spark
#docker build -t hd-hive-pyspark $IMG_PATH/hdspark/pyspark
# docker build -t hdnginx         $IMG_PATH/hdnginx