# docker build -t env-ssh-jdk8 ./env/jdk8/
FROM env-ssh

# install java
ADD jdk-8u144-linux-x64.tar.gz /opt/module/
ENV JAVA_HOME /opt/module/jdk1.8.0_144
ENV PATH $PATH:$JAVA_HOME/bin