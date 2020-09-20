# docker build -t hdnode .
FROM centos:latest as base

RUN echo "alias ll='ls -l'" >> /root/.bashrc

RUN yum -y install which

# ssh
RUN yum -y install passwd openssl openssh-server openssh-clients
RUN mkdir /var/run/sshd/
RUN sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key
RUN ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key
RUN echo 'root:1234'|chpasswd

# ssh copy
RUN yum install -y epel-release
RUN yum install -y sshpass

# save jar
RUN mkdir /opt/module/

# install java
ADD jdk-8u144-linux-x64.tar.gz /opt/module/
ENV JAVA_HOME /opt/module/jdk1.8.0_144
ENV PATH $PATH:$JAVA_HOME/bin

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

ADD run.sh /run.sh
RUN chmod a+x /run.sh

CMD ["/run.sh"]
# CMD ["tail" "-f" "/dev/null"]