# docker build -t env-ssh ./env/ssh
FROM common-env

# ssh
# ssh copy: epel-release、sshpass
RUN yum -y install which passwd openssl openssh-server openssh-clients \
    && yum install -y epel-release \
    && yum install -y sshpass

# 引入ssh 的 main.sh
ADD entrypoint/main.sh $DOCKERENV_ENTRYPOINT/ssh/main.sh
RUN chmod a+x $DOCKERENV_ENTRYPOINT/ssh/main.sh
RUN echo 'ssh' >> $DOCKERENV_ENTRYPOINT/include
