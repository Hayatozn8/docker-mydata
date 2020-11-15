FROM env-zknode

# install hadoop
# ENV HADOOP_VERSION 2.7.2
ENV HADOOP_VERSION 2.10.1
ADD hadoop-$HADOOP_VERSION.tar.gz /opt/module/
ENV HADOOP_HOME=/opt/module/hadoop-$HADOOP_VERSION
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

ADD entrypoint/main.sh $DOCKERENV_ENTRYPOINT/hanode/main.sh
RUN chmod a+x $DOCKERENV_ENTRYPOINT/hanode/main.sh \
    && echo 'hanode' >> $DOCKERENV_ENTRYPOINT/include \
    && ln -s $HADOOP_HOME/etc/hadoop /hdetc

VOLUME /hdetc