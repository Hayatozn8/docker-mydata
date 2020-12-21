#!/bin/bash

echo '----------hbase-------------'

# 写入配置
echo "write hbase-site.xml"
env2conf.sh -e HB_SITE -t xml -c $HBASE_HOME/conf/hbase-site.xml \
            --xmlTemplate='<property><name>@key@</name><value>@value@</value></property>' \
            --xmlAppendTo=configuration

# 写入 regionserver
echo '...write regionservers...'

regionservers=$HB_regionservers
regionservers=(${regionservers//,/ })

> $HBASE_HOME/conf/regionservers
for regionserver in ${regionservers[@]}
do
    # 通过HostName从环境变量中获取对应的IP
    echo "$regionserver" >> $HBASE_HOME/conf/regionservers
done

# 创建 conf/backup-masters
if [ ! -z "$HB_BACKUP_MASTERS" ];then
    touch "$HBASE_HOME/conf/backup-masters"
    for master in ${HB_BACKUP_MASTERS//,/ };do
        echo ${master} >> "$HBASE_HOME/conf/backup-masters"
    done
fi

# $1 ip
# $2 hostname
# function tryRegisterHost()
# {
#     # 如果从未写入过 /etc/hosts，则写入
#     if [ -z  $(grep "$1\s+$2$" /etc/hosts) ]; then
#         echo "$1 $2" >> /etc/hosts
#     fi
# }

# 尝试创建与某个 IP/hostname 下的 user 的 ssh 连接
# $1 user
# $2 IP/hostname
function tryCreateSSHConnect()
{
    sshTarget="$1@$2"
    # 尝试进行 ssh 连接，并且失败时不重试
    # 失败时会输出异常 Host key verification failed.
    ssh -o NumberOfPasswordPrompts=0 $sshTarget "pwd"
    # 如果无法通过 ssh 进行连接，则创建连接
    if [ $? != 0 ]; then
        echo "can't connect $sshTarget, try to create connection"
        createSSHConnect.sh $sshTarget
    fi
}

# 启动HBase集群
if [ "$HB_MASTER" = 'true' ];then
    # 与高可用集群的其他master结点建立ssh连接
    if [ ! -z "$HB_BACKUP_MASTERS" ];then
        for master in ${HB_BACKUP_MASTERS//,/ };do
            tryCreateSSHConnect "root" $master
        done
    fi

    start-hbase.sh
fi