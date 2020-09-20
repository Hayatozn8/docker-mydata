ln -s 源文件 目标文件
ln -s 目标路径 链接路径

docker run -it --name testcentos centos:latest
https://blog.csdn.net/xs20691718/article/details/79502019
docker build -f /Users/liujinsuo/myhadoop/incontainer/DockerFile -t javatest .
docker build -t javatest .
docker build -t hdcluster .
docker run -it --name='javatest01' javatest
docker run -it --name='javatest01' -v=/Users/liujinsuo/myhadoop/incontainer/test/hdconf:/hdetc javatest
docker rmi javatest
docker rmi hdcluster
docker rm javatest01
docker rm myhd02
docker rm hd02

docker rm myct
docker run -it --name='myct' centos
service ssh start

docker cp /Users/liujinsuo/myhadoop/incontainer/hadoop-2.7.2/lib javatest01:/opt/module/hadoop-2.7.2/lib


docker run -it --name='hd02' --add-host=hd03:172.22.101.3  --add-host=hd04:172.22.101.4 -v=/Users/liujinsuo/myhadoop/incontainer/test/hdconf:/hdetc -p=50090:50090 -p=50070:50070 -p=19888:19888 --net=hdnet --ip=172.22.101.2 -h=hd02 javatest /bin/bash

docker run -d --name='hd02' --add-host=hd03:172.22.101.3  --add-host=hd04:172.22.101.4 -v=/Users/liujinsuo/myhadoop/incontainer/test/hdconf:/hdetc -p=50090:50090 -p=50070:50070 -p=19888:19888 --net=hdnet --ip=172.22.101.2 -h=hd02 javatest

docker run -d --name='hd02' --add-host=hd03:172.22.101.3  --add-host=hd04:172.22.101.4 -v=/Users/liujinsuo/myhadoop/incontainer/test/hdconf:/hdetc -p=50090:50090 -p=50070:50070 -p=19888:19888 --net=hdnet --ip=172.22.101.2 -h=hd02 --env-file=/Users/liujinsuo/myhadoop/incontainer/hd.env hdimg

docker run -d --name='hd03' --add-host=hd02:172.22.101.2  --add-host=hd04:172.22.101.4 -v=/Users/liujinsuo/myhadoop/incontainer/test/hdconf:/hdetc  --net=hdnet --ip=172.22.101.3 -h=hd03 javatest

docker run -d --name='hd04' --add-host=hd02:172.22.101.2  --add-host=hd03:172.22.101.3 -v=/Users/liujinsuo/myhadoop/incontainer/test/hdconf:/hdetc  --net=hdnet --ip=172.22.101.4 -h=hd04 javatest

docker network create -d bridge --subnet=172.22.0.0/16 hdnet

docker exec -it hd02 /bin/bash
docker exec -it hd03 /bin/bash
docker exec -it hd04 /bin/bash

hadoop-daemon.sh stop datanode


172.22.101.1:50070

docker exec -it myhd02 /bin/bash
------------------------------------------------

- 一个配置文件，配追集群中的初始状态
    - NN、DN、RM、NM、H
- 启动时sh读取，根据主机名判断如何启动，以及向谁拷贝信息

docker run -d --name='hdnginx01' --net=incontainer_hdxnet --ip=172.23.101.100 -p 50070:50070 -p 8088:8088 -p 19888:19888 hdnginx


docker rm $(docker stop hdnginx01)
docker rmi hdnginx
docker build -t hdnginx .

hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.2.jar wordcount /user/input/word.txt /user/input/wordresult


docker run -d --name='hdnginx01' --net=incontainer_hdxnet --ip=172.23.101.100 -p 50070:50070 -p 8088:8088 -p 19888:19888 -v /Users/liujinsuo/myhadoop/incontainer/log:/var/log/nginx hdnginx

docker run -itd -v  /Users/liujinsuo/myhadoop/incontainer/log:/var/log/nginx -p 8089:80 nginx


- nginx映射
- 自动启动
    - mr-jobhistory-daemon.sh start historyserver

- spark测试
```sh
spark-submit \
--class org.apache.spark.examples.SparkPi \
--master yarn \
$SPARK_HOME/examples/jars/spark-examples_2.12-3.0.1.jar \
10
```