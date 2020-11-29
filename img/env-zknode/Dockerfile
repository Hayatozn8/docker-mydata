FROM env-ssh

ARG pkg

ADD src/entrypoint/main.sh $DOCKERENV_ENTRYPOINT/zknode/main.sh
ADD ${pkg} /opt/module/

RUN mv /opt/module/zookeeper* /opt/module/zookeeper
ENV ZOOKEEPER_HOME /opt/module/zookeeper
ENV ZOOKEEPER_DATA $ZOOKEEPER_HOME/zkdata
ENV PATH $PATH:$ZOOKEEPER_HOME/bin

RUN chmod a+x $DOCKERENV_ENTRYPOINT/zknode/main.sh \
 && echo 'zknode' >> $ENTRYPOINT_INCLUDE \
 && mkdir /zkdata \
 && mv $ZOOKEEPER_HOME/conf/zoo_sample.cfg $ZOOKEEPER_HOME/conf/zoo.cfg \
 && sed -i "s@dataDir=.*@dataDir=\/zkdata@g" $ZOOKEEPER_HOME/conf/zoo.cfg \
 && ln -s $ZOOKEEPER_HOME/conf /zkconfig

VOLUME /zkconfig