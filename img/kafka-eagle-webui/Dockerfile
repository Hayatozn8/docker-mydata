FROM kafka-base

# 添加 eagle 的安装包
# 需要1.4以上版本，否则会产生异常
# java.lang.NoClassDefFoundError: Could not 
# initialize class com.fasterxml.jackson.annotation.JsonInclude$Value
ADD kafka-eagle-web-1.4.8-bin.tar.gz /opt/module/
ENV KE_HOME=/opt/module/eagle
ENV PATH=$PATH:$KE_HOME/bin
ADD entrypoint/main.sh $DOCKERENV_ENTRYPOINT/kafka/eagle/webui/main.sh 

# 添加mysql8驱动
ARG MYSQL_CONNECT_VER=8.0.19
ARG MYSQL_CONNECT_NAME=mysql-connector-java-$MYSQL_CONNECT_VER
ADD $MYSQL_CONNECT_NAME.tar.gz /opt/module/

# 修改 kafka-server-start.sh 的启动命令
# JMX的
RUN sed -i "s@export KAFKA_HEAP_OPTS=\"-Xmx1G -Xms1G\"@export KAFKA_HEAP_OPTS=\"-server -Xms2G -Xmx2G -XX:PermSize=128m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:ParallelGCThreads=8 -XX:ConcGCThreads=5 -XX:InitiatingHeapOccupancyPercent=70\"\n    export JMX_PORT=\"9998\"@" $KAFKA_HOME/bin/kafka-server-start.sh \
    && mv /opt/module/kafka-eagle* /opt/module/eagle \
    && chmod 777 $KE_HOME/bin/ke.sh \
    && echo 'kafka/eagle/webui' >> $DOCKERENV_ENTRYPOINT/include \
    && mv /opt/module/$MYSQL_CONNECT_NAME/$MYSQL_CONNECT_NAME.jar $KE_HOME/kms/lib/