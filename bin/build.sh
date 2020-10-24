IMG_PATH="$(cd `dirname $0`;pwd)/../img"
docker build -t common-env      $IMG_PATH/env/common
docker build -t env-ssh         $IMG_PATH/env/ssh
docker build -t env-ssh-jdk8    $IMG_PATH/env/jdk8/
docker build -t hdnode          $IMG_PATH/env/hdnode
docker build -t hanode          $IMG_PATH/env/hanode
docker build -t hd-hive-base    $IMG_PATH/hive/base
docker build -t hd-hive-spark   $IMG_PATH/hdspark/hd-hive-spark
#docker build -t hd-hive-pyspark $IMG_PATH/hdspark/pyspark
docker build -t hdnginx         $IMG_PATH/hdnginx