# docker build -t env-ssh-jdk8 ./env/jdk8/
FROM env-ssh

ADD jdk-8u144-linux-x64.tar.gz /opt/module/
ENV JAVA_HOME /opt/module/jdk1.8.0_144
ENV PATH $PATH:$JAVA_HOME/bin
# ARG JDK_LOCAL_PATH
# ARG JDK_DIR_NAME
# ADD $JDK_LOCAL_PATH /opt/module/
# ENV JAVA_HOME /opt/module/JDK_DIR_NAME
# ENV PATH $PATH:$JAVA_HOME/bin