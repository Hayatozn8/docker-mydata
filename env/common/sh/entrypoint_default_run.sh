#!bin/bash

sh $DOCKERENV/import.sh entrypoint

# 吸收 cmd 的指令与参数
# 如果未添加 cmd ，则保持容器的运行
# 如果添加了cmd，则执行cmd
if [ $# -eq 0 ]; then
    
else 
    exec $@
fi
