FROM kafka-base

# 修改 kafka-server-start.sh 的启动命令
# export KAFKA_HEAP_OPTS="-server -Xms2G -Xmx2G -XX:PermSize=128m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:ParallelGCThreads=8 - XX:ConcGCThreads=5 -XX:InitiatingHeapOccupancyPercent=70"
# export JMX_PORT="9999"
RUN sed -i "s@export KAFKA_HEAP_OPTS=\"-Xmx1G -Xms1G\"@export KAFKA_HEAP_OPTS=\"-server -Xms2G -Xmx2G -XX:PermSize=128m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:ParallelGCThreads=8 -XX:ConcGCThreads=5 -XX:InitiatingHeapOccupancyPercent=70\"\n    export JMX_PORT=\"9998\"@" $KAFKA_HOME/bin/kafka-server-start.sh