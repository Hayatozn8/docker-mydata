FROM env-ssh

ADD entrypoint/main.sh $DOCKERENV_ENTRYPOINT/zknode/main.sh
ENV ZOOKEEPER_VERSION 3.4.14
ENV ZOOKEEPER_HOME /opt/module/zookeeper-$ZOOKEEPER_VERSION
ENV ZOOKEEPER_DATA $ZOOKEEPER_HOME/zkdata
ADD zookeeper-$ZOOKEEPER_VERSION.tar.gz /opt/module/
ENV PATH $PATH:$ZOOKEEPER_HOME/bin

RUN chmod a+x $DOCKERENV_ENTRYPOINT/zknode/main.sh \
 && echo 'zknode' >> $DOCKERENV_ENTRYPOINT/include \
 && mkdir /zkdata \
 && mv $ZOOKEEPER_HOME/conf/zoo_sample.cfg $ZOOKEEPER_HOME/conf/zoo.cfg \
 && sed -i "s@dataDir=.*@dataDir=\/zkdata@g" $ZOOKEEPER_HOME/conf/zoo.cfg\
 && ln -s $ZOOKEEPER_HOME/conf /zkconfig

VOLUME /zkconfig