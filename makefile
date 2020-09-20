docker build -t env-ssh ./env/ssh
docker build -t env-ssh-jdk8 ./env/jdk8/
docker build -t hdnode ./hdnode
docker build -t hdspark ./hdspark
docker-compose up -d