# docker build -t env-ssh ./env/ssh
FROM centos:latest as base

RUN echo "alias ll='ls -l'" >> /root/.bashrc

# ssh
# ssh copy: epel-release、sshpass
RUN yum -y install which passwd openssl openssh-server openssh-clients \
    && yum install -y epel-release \
    && yum install -y sshpass

ADD entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]