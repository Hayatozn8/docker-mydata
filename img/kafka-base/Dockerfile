FROM env-jdk8

# 添加 kafak 安装包
ADD kafka_2.11-0.11.0.0.tgz /opt/module/
ENV KAFKA_HOME /opt/module/kafka
ENV PATH $PATH:$KAFKA_HOME/bin

# 引入 kafka 的 main.sh
ADD entrypoint/main.sh $DOCKERENV_ENTRYPOINT/kafka/base/main.sh

RUN mv /opt/module/kafka* /opt/module/kafka \
    && chmod a+x $DOCKERENV_ENTRYPOINT/kafka/base/main.sh \
    && echo 'kafka/base' >> $DOCKERENV_ENTRYPOINT/include \
    && mkdir /kafkaConfig \
    && cp /opt/module/kafka/config/server.properties /kafkaConfig/server.properties

VOLUME [ "/kafkaConfig" ]