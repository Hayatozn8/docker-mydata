FROM hbase

ARG pkg
ARG HBASE_HBASE_JAR_VERSION
ARG MYSQL8_CONNECT_JAR

# 配置 hive
ADD ${pkg} /opt/module/
ENV HIVE_HOME /opt/module/hive
ENV PATH $PATH:$HIVE_HOME/bin

ADD src/entrypoint/main.sh $DOCKERENV_ENTRYPOINT/hive/main.sh

RUN mv /opt/module/apache-hive-* /opt/module/hive \
    && cp $HIVE_HOME/conf/hive-env.sh.template $HIVE_HOME/conf/hive-env.sh \
    && echo "export HADOOP_HOME=$HADOOP_HOME" >> $HIVE_HOME/conf/hive-env.sh \
    && echo "export HIVE_CONF_DIR=$HIVE_HOME/conf" >> $HIVE_HOME/conf/hive-env.sh \
    && chmod a+x $DOCKERENV_ENTRYPOINT/hive/main.sh \
    && echo 'hive' >> $DOCKERENV_ENTRYPOINT/include \
    && echo '<?xml version="1.0"?>' >> $HIVE_HOME/conf/hive-site.xml \
    && echo '<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>' >> $HIVE_HOME/conf/hive-site.xml \
    && echo '<configuration>' >> $HIVE_HOME/conf/hive-site.xml \
    && echo '</configuration>' >> $HIVE_HOME/conf/hive-site.xml \
    && ln -s $HBASE_HOME/lib/hbase-common-${HBASE_JAR_VERSION}.jar $HIVE_HOME/lib/hbase-common-${HBASE_JAR_VERSION}.jar \
    && ln -s $HBASE_HOME/lib/hbase-server-${HBASE_JAR_VERSION}.jar $HIVE_HOME/lib/hbase-server-${HBASE_JAR_VERSION}.jar \
    && ln -s $HBASE_HOME/lib/hbase-client-${HBASE_JAR_VERSION}.jar $HIVE_HOME/lib/hbase-client-${HBASE_JAR_VERSION}.jar \
    && ln -s $HBASE_HOME/lib/hbase-protocol-${HBASE_JAR_VERSION}.jar $HIVE_HOME/lib/hbase-protocol-${HBASE_JAR_VERSION}.jar \
    && ln -s $HBASE_HOME/lib/hbase-it-${HBASE_JAR_VERSION}.jar $HIVE_HOME/lib/hbase-it-${HBASE_JAR_VERSION}.jar \
    # && ln -s $HBASE_HOME/lib/htrace-core-3.1.0-incubating.jar $HIVE_HOME/lib/htrace-core-3.1.0-incubating.jar \
    && ln -s $HBASE_HOME/lib/hbase-hadoop2-compat-${HBASE_JAR_VERSION}.jar $HIVE_HOME/lib/hbase-hadoop2-compat-${HBASE_JAR_VERSION}.jar \
    && ln -s $HBASE_HOME/lib/hbase-hadoop-compat-${HBASE_JAR_VERSION}.jar $HIVE_HOME/lib/hbase-hadoop-compat-${HBASE_JAR_VERSION}.jar

# 配置 mysql8 jar包
ADD ${MYSQL8_CONNECT_JAR} $HIVE_HOME/lib/
