FROM env-hanode

ARG pkg
ADD ${pkg} /opt/module/

ENV HBASE_HOME /opt/module/hbase
ENV PATH $PATH:$HBASE_HOME/bin

ADD src/entrypoint/main.sh $DOCKERENV_ENTRYPOINT/hbase/main.sh

RUN mv /opt/module/hbase* /opt/module/hbase \
    && chmod a+x $DOCKERENV_ENTRYPOINT/hbase/main.sh \
    && echo 'hbase' >> $ENTRYPOINT_INCLUDE \
    && echo "export JAVA_HOME=${JAVA_HOME}" >> $HBASE_HOME/conf/hbase-env.sh \
    && echo 'export HBASE_MANAGES_ZK=false' >> $HBASE_HOME/conf/hbase-env.sh \
    && echo 'export HADOOP_CLASSPATH=$HADOOP_CLASSPATH:/opt/module/hbase/lib/*' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh \
    && sed -ir 's/^export HBASE_MASTER_OPTS=.*/#&/' $HBASE_HOME/conf/hbase-env.sh \
    && sed -ir 's/^export HBASE_REGIONSERVER_OPTS=.*/#&/' $HBASE_HOME/conf/hbase-env.sh \
    && ln -s $HADOOP_HOME/etc/hadoop/core-site.xml $HBASE_HOME/conf/core-site.xml \
    && ln -s $HADOOP_HOME/etc/hadoop/hdfs-site.xml $HBASE_HOME/conf/hdfs-site.xml
