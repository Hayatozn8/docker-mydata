# docker build -t hd-hive-base ./hive/base
FROM hdnode:latest

# 配置 hive
ARG HIVE_VERSION=2.3.7
ADD apache-hive-$HIVE_VERSION-bin.tar.gz /opt/module/
ENV HIVE_HOME /opt/module/apache-hive-$HIVE_VERSION-bin
ENV PATH $PATH:$HIVE_HOME/bin

RUN cp $HIVE_HOME/conf/hive-env.sh.template $HIVE_HOME/conf/hive-env.sh \
    && echo "export HADOOP_HOME=$HADOOP_HOME" >> $HIVE_HOME/conf/hive-env.sh \
    && echo "export HIVE_CONF_DIR=$HIVE_HOME/conf" >> $HIVE_HOME/conf/hive-env.sh

# 配置 mysql
# TODO 如何提取 mysql id
ADD hive-site.xml $HIVE_HOME/conf/hive-site.xml
ARG MYSQL_CONNECT_VER=8.0.19
ARG MYSQL_CONNECT_NAME=mysql-connector-java-$MYSQL_CONNECT_VER
ADD $MYSQL_CONNECT_NAME.tar.gz /opt/module/

# 引入 hive 的 main.sh ，并将mysql-connect的jar包移动到 hive/lib 下
ADD entrypoint/main.sh $DOCKERENV_ENTRYPOINT/hive/main.sh
RUN chmod a+x $DOCKERENV_ENTRYPOINT/hive/main.sh \
    && echo 'hive' >> $DOCKERENV_ENTRYPOINT/include \
    && mv /opt/module/$MYSQL_CONNECT_NAME/$MYSQL_CONNECT_NAME.jar $HIVE_HOME/lib/
