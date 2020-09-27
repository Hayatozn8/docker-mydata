docker build -t common-env ./env/common
docker build -t env-ssh ./env/ssh
docker build -t env-ssh-jdk8 ./env/jdk8/
docker build -t hdnode ./hdnode
docker build -t hdspark ./hdspark
docker build -t hdnginx ./hdnginx
docker-compose -f hdcluster/docker-compose_hd.yml up -d
docker-compose -f hdcluster/docker-compose_hd.yml ps
docker-compose -f hdcluster/docker-compose_hd.yml down
docker-compose -f hdcluster/docker-compose_hd_zk.yml up -d


---zookeeper
docker build -t zklocal ./zookeeper -f ./zookeeper/local/Dockerfile



docker run -it --name='hd02' --add-host=hd03:172.22.101.3  --add-host=hd04:172.22.101.4 -v=/Users/liujinsuo/myhadoop/incontainer/test/hdconf:/hdetc -p=50090:50090 -p=50070:50070 -p=19888:19888 --net=hdnet --ip=172.22.101.2 -h=hd02 env-ssh /bin/bash

- common-env
docker run -it --name='hd02' --add-host=hd03:172.23.101.11 --net=hdcluster_hdxnet --ip=172.23.101.10 -h=hd02 common-env
docker rm hd02
sh $DOCKERENV/entrypoint_default_run.sh

docker run -d --name='hd02' --add-host=hd03:172.23.101.11 --net=hdcluster_hdxnet --ip=172.23.101.10 -h=hd02 env-ssh
docker run -d --name='hd03' --add-host=hd02:172.22.101.10 --net=hdcluster_hdxnet --ip=172.23.101.11 -h=hd03 env-ssh