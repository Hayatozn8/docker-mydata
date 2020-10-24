BASE_PATH="$(cd `dirname $0`;pwd)/.."
docker build -t common-env      $BASE_PATH/env/common
docker build -t env-ssh         $BASE_PATH/env/ssh
docker build -t env-ssh-jdk8    $BASE_PATH/env/jdk8/
docker build -t hdnode          $BASE_PATH/env/hdnode
docker build -t hanode          $BASE_PATH/env/hanode
docker build -t hd-hive-base    $BASE_PATH/hive/base
docker build -t hd-hive-spark   $BASE_PATH/hdspark/hd-hive-spark
#docker build -t hd-hive-pyspark $BASE_PATH/hdspark/pyspark
docker build -t hdnginx         $BASE_PATH/hdnginx