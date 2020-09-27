#!bin/bash

sh $DOCKERENV/import.sh entrypoint

# 吸收 cmd 的指令与参数，并执行
exec $@