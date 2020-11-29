#!/bin/bash

echo "------------entrypoint default run-----------------"

sh $DOCKERENV/import.sh entrypoint

if [ $# -eq 0 ]; then
    # 如果未添加 cmd ，则保持容器的运行
    echo "------------cmd is null-----------------"

    tail -f /dev/null
else
    # 吸收 cmd 的指令与参数
    # 如果有cmd，则执行cmd
    echo "------------run cmd-----------------"

    exec $@
fi
