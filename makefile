docker build -t env-ssh ./env/ssh
docker build -t env-ssh-jdk8 ./env/jdk8/
docker build -t hdnode ./hdnode
docker build -t hdspark ./hdspark
docker-compose -f hdcluster/docker-compose_hd.yml up -d
docker-compose -f hdcluster/docker-compose_hd_zk.yml up -d


---zookeeper
docker build -t zklocal ./zookeeper -f ./zookeeper/local/Dockerfile