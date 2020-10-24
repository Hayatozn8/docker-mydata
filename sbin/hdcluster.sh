CONF_PATH="$(cd `dirname $0`;pwd)/../conf"
docker-compose -f $CONF_PATH/hdcluster/docker-compose_hd.yml $@
# docker-compose -f hdcluster/docker-compose_hd.yml up -d
# docker-compose -f hdcluster/docker-compose_hd.yml ps
# docker-compose -f hdcluster/docker-compose_hd.yml down