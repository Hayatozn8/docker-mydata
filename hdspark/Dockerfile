# docker build -t hd-hive-hdspark ./hdspark
FROM hd-hive-base

ADD spark-3.0.1-bin-without-hadoop.tgz /opt/module/
ENV SPARK_HOME /opt/module/spark-3.0.1-bin-without-hadoop
ENV PATH $PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin

RUN echo -e "SPARK_DIST_CLASSPATH=\$($HADOOP_HOME/bin/hadoop classpath)\n\
export JAVA_HOME=$JAVA_HOME\n\
YARN_CONF_DIR=$HADOOP_HOME/etc/hadoop\n" > $SPARK_HOME/conf/spark-env.sh