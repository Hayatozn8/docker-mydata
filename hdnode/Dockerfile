# docker build -t hdnode ./hdnode
FROM env-ssh-jdk8 as base

# install hadoop
ENV HADOOP_VERSION 2.7.2
ADD hadoop-$HADOOP_VERSION.tar.gz /opt/module/
ENV HADOOP_HOME=/opt/module/hadoop-$HADOOP_VERSION
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

#################################################################
FROM base
# creat link for config of hadoop 
RUN ln -s $HADOOP_HOME/etc/hadoop /hdetc

VOLUME /hdetc

ADD entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
# CMD ["tail" "-f" "/dev/null"]