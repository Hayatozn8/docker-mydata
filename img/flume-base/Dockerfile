FROM env-jdk8

# 添加 flume 安装包
ARG pkg
ADD ${pkg} /opt/module/
ENV FLUME_HOME /opt/module/flume
ENV PATH $PATH:$FLUME_HOME/bin

ADD src/entrypoint/main.sh $DOCKERENV_ENTRYPOINT/flume/main.sh

RUN mv /opt/module/apache-flume* /opt/module/flume \
    && mv $FLUME_HOME/conf/flume-env.sh.template $FLUME_HOME/conf/flume-env.sh \
    && echo "export JAVA_HOME=$JAVA_HOME" >> $FLUME_HOME/conf/flume-env.sh \
    && mkdir -p /flume/conf \
    && chmod a+x $DOCKERENV_ENTRYPOINT/flume/main.sh \
    && echo 'flume' >> $DOCKERENV_ENTRYPOINT/include

# ADD src/conf/base.conf /flume/conf/base.conf

VOLUME [ "/flume/conf" ]

# CMD [ "flume-ng", "agent", "-n", "a1", "-c", "${FLUME_HOME}/conf", "-f", "/flume/conf/base.conf", "-Dflume.root.logger=INFO,console" ]
CMD [ "flume-ng", "agent", "-n", "a1", "-c", "/opt/module/flume/conf", "-f", "/flume/conf/base.conf" ]

