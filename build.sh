docker build -t common-env ./env/common
docker build -t env-ssh ./env/ssh
docker build -t env-ssh-jdk8 ./env/jdk8/
docker build -t hdnode ./env/hdnode
docker build -t hd-hive-base ./hive/base
docker build -t hd-hive-spark ./hdspark
docker build -t hdnginx ./hdnginx
# docker-compose -f hdcluster/docker-compose_hd.yml up -d
# docker-compose -f hdcluster/docker-compose_hd.yml ps
# docker-compose -f hdcluster/docker-compose_hd.yml down
# docker-compose -f hdcluster/docker-compose_hd_zk.yml up -d