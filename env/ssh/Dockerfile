# docker build -t env-ssh ./env/ssh
FROM centos:latest as base

RUN echo "alias ll='ls -l'" >> /root/.bashrc

# ssh
# ssh copy: epel-release、sshpass
RUN yum -y install which passwd openssl openssh-server openssh-clients \
    && yum install -y epel-release \
    && yum install -y sshpass \
    && mkdir /var/run/sshd/ \
    && sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config \
    && ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key \
    && ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key \
    && ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key \
    && echo 'root:1234'|chpasswd