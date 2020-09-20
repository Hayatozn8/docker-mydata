#!bin/bash
echo "--------------ssh-------------------"
mkdir /var/run/sshd/
sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config
ssh-keygen -t rsa -N '' -f /etc/ssh/ssh_host_rsa_key
ssh-keygen -t ecdsa -N '' -f /etc/ssh/ssh_host_ecdsa_key
ssh-keygen -t ed25519 -N '' -f /etc/ssh/ssh_host_ed25519_key
echo 'root:1234'|chpasswd

mkdir $HOME/.ssh
ssh-keygen -t rsa -N '' -f $HOME/.ssh/id_rsa

/usr/sbin/sshd -D &

exec $@