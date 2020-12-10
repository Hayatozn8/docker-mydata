# FROM env-zknode
FROM env-ssh

ARG pkg
ADD ${pkg} /opt/module/
ENV HADOOP_HOME=/opt/module/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

ADD src/entrypoint/main.sh $DOCKERENV_ENTRYPOINT/hanode/main.sh

RUN mv /opt/module/hadoop* /opt/module/hadoop \
    && chmod a+x $DOCKERENV_ENTRYPOINT/hanode/main.sh \
    && echo 'hanode' >> $DOCKERENV_ENTRYPOINT/include \
    && echo "export JAVA_HOME=${JAVA_HOME}" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh \
    && ln -s $HADOOP_HOME/etc/hadoop /hdetc

VOLUME /hdetc

# HA_CORE
# HA_HDFS
# HA_YARN
# HA_MR