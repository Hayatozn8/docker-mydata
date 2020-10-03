# docker build -t hanode ./hanode
FROM hdnode

ADD entrypoint/main.sh $DOCKERENV_ENTRYPOINT/hanode/main.sh
ENV ZK_VERSION 3.4.14
ENV ZK_HOME /opt/module/zookeeper-$ZK_VERSION
ENV ZK_DATA $ZK_HOME/zkdata
ADD zookeeper-$ZK_VERSION.tar.gz /opt/module/
ENV PATH $PATH:$ZK_HOME/bin

# RUN yum -y install psmisc \
RUN chmod a+x $DOCKERENV_ENTRYPOINT/hanode/main.sh \
 && echo 'hanode' >> $DOCKERENV_ENTRYPOINT/include \
 && echo 'hdnode' >> $DOCKERENV_ENTRYPOINT/exclude \
 && mkdir /zkdata \
 && ln -s $ZK_HOME/conf/zoo.cfg /zoo.cfg

VOLUME /zoo.cfg