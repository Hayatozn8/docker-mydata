# docker build -t zklocal ./zookeeper -f ./zookeeper/local/Dockerfile
FROM env-ssh-jdk8

# install zookeeper
ENV ZK_VERSION 3.4.14
ENV ZK_HOME=/opt/module/zookeeper-$ZK_VERSION
ADD zookeeper-$ZK_VERSION.tar.gz /opt/module/
ENV PATH=$PATH:$ZK_HOME/bin

# creat link for config of zookeeper 
RUN mkdir /zkdata \
    && ln -s $ZK_HOME/conf/zoo.cfg /zoo.cfg

VOLUME /zkdata
VOLUME /zoo.cfg

CMD [ "tail", "-f", "/dev/null" ]