FROM env-common

# ssh
# ssh copy: epel-release、sshpass
RUN yum -y install which passwd openssl openssh-server openssh-clients \
    && yum install -y epel-release \
    && yum install -y sshpass

# 引入ssh 的 main.sh
ADD entrypoint/main.sh $DOCKERENV_ENTRYPOINT/ssh/main.sh
# 添加ssh连接shell
ADD sh/createSSHConnect.sh /usr/bin/createSSHConnect.sh

# 添加 main.sh，并设置个shell的可执行权限
RUN chmod a+x $DOCKERENV_ENTRYPOINT/ssh/main.sh \
    && echo 'ssh' >> $DOCKERENV_ENTRYPOINT/include \
    && chmod a+x /usr/bin/createSSHConnect.sh
