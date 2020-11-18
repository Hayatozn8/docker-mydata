#!/bin/bash

# sh sbin/compose.sh XXX up -d
# sh sbin/compose.sh XXX down

# CONF_PATH="$(cd `dirname $0`;pwd)/../conf"
docker-compose -f $1/docker-compose.yml ${@:2:$#-1}