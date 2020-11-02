# docker build -t zknode ./zknode
FROM env-ssh-jdk8

ADD entrypoint/main.sh $DOCKERENV_ENTRYPOINT/zknode/main.sh
ENV ZOOKEEPER_VERSION 3.4.14
ENV ZOOKEEPER_HOME /opt/module/zookeeper-$ZOOKEEPER_VERSION
ENV ZOOKEEPER_DATA $ZOOKEEPER_HOME/zkdata
ADD zookeeper-$ZOOKEEPER_VERSION.tar.gz /opt/module/
ENV PATH $PATH:$ZOOKEEPER_HOME/bin

RUN chmod a+x $DOCKERENV_ENTRYPOINT/zknode/main.sh \
 && echo 'zknode' >> $DOCKERENV_ENTRYPOINT/include \
 && cp $ZOOKEEPER_HOME/conf/zoo_sample.cfg $ZOOKEEPER_HOME/conf/zoo.cfg \
 && sed -i "s@dataDir=.*@dataDir=\/zkdata@g" $ZOOKEEPER_HOME/conf/zoo.cfg\
 && mkdir /zkdata
 #&& ln -s $ZOOKEEPER_HOME/conf/zoo.cfg /zoo.cfg

# VOLUME /zoo.cfg
# VOLUME $ZOOKEEPER_HOME/conf/zoo.cfg