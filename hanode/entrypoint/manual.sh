#!bin/bash
echo "--------------hanode-------------------"

# 缓存已经被写入过的 hosts
registeredHosts=()

# 缓存已经被写入过的 ssh 用户: user@hostname
registeredSSHUserHosts=()

# 尝试将 hostname、ip 写入 /etc/hosts
# $1 hostname
# $2 ip
# @return y=成功写入; n=已经写过了，不需要再写一次
function tryRegisterHost()
{
    local hostname=$1
    local ip=$2

    for rh in ${registeredHosts[@]}
    do
        #  如果当前 host 已经被写入过 /etc/hosts，则跳过当前处理
        if [ $hostname = $rh ]; then
            echo "n"
            return 0
        fi
    done

    # 如果从未写入过 /etc/hosts，则写入
    registeredHosts[${#registeredHosts[@]}]="$hostname"
    echo "$ip $hostname" >> /etc/hosts

    echo "y"
}

# 尝试将所有JN的 host 写入 /etc/hosts
function tryRegisterHostForJN()
{
    local jnList=$JNS
    jnList=(${jnList//,/ })

    for jnHost in ${jnList[@]}
    do
        eval jnip='$'$jnHost
        tryRegisterHost $jnHost $jnip
    done
}

# 尝试将 RM 的 host 写入 /etc/hosts
function tryRegisterHostForRM()
{
    local rnHost=$RN
    eval rnip='$'$rnHost
    tryRegisterHost $rnip $rnHost
}

# 尝试通过 ssh 连接某个 user@host
# $1 hostname
# $2 user
# @return y=成功连接; n=已经连接过了，不需要再连接一次
function tryRegisterSSHUserHost()
{
    local hostname=$1
    local user=$2
    local sshTarget="$user@$hostname"

    for rsuh in ${registeredSSHUserHosts[@]}
    do
        #  如果当前 user@host 已经连接过，则不需要再连接一次，跳过当前处理
        if [ $sshTarget = $rsuh ]; then
            echo "n"
            return 0
        fi
    done

    # 如果从未连接过 user@host，则尝试连接
    registeredSSHUserHosts[${#registeredSSHUserHosts[@]}]="$sshTarget"
    sshpass -p '1234' ssh-copy-id -o StrictHostKeyChecking=no $sshTarget > /dev/null 2>&1

    echo "y"
}

# 尝试用 ssh 连接所有的 JN
function tryRegisterSSHUserHostForJN()
{
    local jnList=$JNS
    jnList=(${jnList//,/ })

    for jnHost in ${jnList[@]}
    do
        eval jnip='$'$jnHost
        tryRegisterSSHUserHost $jnHost root
    done
}

# 检查结点是否为 JN
function isJN()
{
    local hostname=$1
    # 获取所有JN的id
    local jnList=$JNS
    jnList=(${jnList//,/ })
    
    for jnNode in ${jnList[@]}
    do
        if [ $hostname = $jnNode ]; then
            echo "y"
            return 0
        fi
    done

    echo "n"
}

# - 将 slave 的地址写入host
# - 搜索 slave 开始向所有salve发送ssh密钥
function sshConnectSlaves()
{
    # 获取所有 slaves 的 id
    local slaves=$SLAVES
    slaves=(${slaves//,/ })
    
    for slaveHostName in ${slaves[@]}
    do
        # 将slave的地址写入host
        eval slaveIP='$'$slaveHostName

        # 尝试将 slave 的地址写入host
        tryRegisterHost $slaveHostName $slaveIP

        # 尝试建立 ssh 连接
        tryRegisterSSHUserHost $slaveHostName "root"
    done
}

function sshConnectNN()
{
    nnName=$NN
    eval nnip='$'$nnName
    echo "$nnip  $nnName" >> /etc/hosts
    
    sshpass -p '1234' ssh-copy-id -o StrictHostKeyChecking=no root@${nnName} > /dev/null 2>&1
}

# ssh 连接自己
function sshConnectSelf()
{
    # 获取 hostname 和 ip
    local hostname=$1
    eval selfIP='$'$hostname

    # 尝试将 self 的地址写入host
    tryRegisterHost $hostname $selfIP

    # 尝试建立 ssh 连接
    tryRegisterSSHUserHost $hostname "root"
}

# 尝试启动 第一个mainJN节点，即JNS中的第一个JN节点
function tryStartMainJN()
{
    local hostname=$1
    
    # 获取所有JN的id
    local jnList=$JNS
    jnList=(${jnList//,/ })

    # 1. 检查 hostname 是不是mani JN 节点 (即 JNS 的第一个节点)
    # 如果不是则返回
    if [ $hostname != ${jnList[0]} ]; then
        return 0
    fi

    # 3. 启动整个高可用集群
    # 格式化 nn
    hdfs namenode -format
    # 启动当前nn结点
    hadoop-daemon.sh start namenode
    # 其他slaves 循环执行
    for jnHost in ${jnList[@]}
    do
        # 同步元数据
        ssh "root@$jnHost" "$HADOOP_HOME/bin/hdfs namenode -bootstrapStandby"
        # 远程启动 nn
        ssh "root@$jnHost" "$HADOOP_HOME/sbin/hadoop-daemon.sh start namenode"
    done

    # 启动所有的dn
    hadoop-daemons.sh start datanode

    # 激活当前的main jn 节点
    hdfs haadmin -transitionToActive nn1
}

#  启动 JN 结点
function startJN()
{
    hadoop-daemon.sh start journalnode
}

#  启动 RM 结点
function startRM()
{
    # 创建日志目录
    mkdir $HADOOP_HOME/logs
    # 启动 yarn
    start-yarn.sh
}

# 1. 我是谁
hostname=$(hostname)
matched=0
# 2. 如果是JN
if [ $(isJN $hostname) = 'y' ]; then
    # 与自身建立 ssh 连接
    sshConnectSelf $hostname
    # 与所有 slave 建立连接
    sshConnectSlaves
    # 与其他 JN 互联
    tryRegisterHostForJN
    tryRegisterSSHUserHostForJN
    # 注册zookeeper信息
    
    # 启动JN
    startJN
    # 如果是main jn，即第一个 jn，则尝试启动所有的dn
    tryStartMainJN $hostname
fi

# 3. 如果是 RM
if [ "$hostname" = "$RM" ]; then
    # 与自身建立 ssh 连接
    sshConnectSelf $hostname
    # 与所有 slave 建立连接
    sshConnectSlaves
    #  启动 RM 结点
    startRM
fi

# 4. 如果是slave
if [ "$matched" == '0' ]; then
    # 将 JN 写入host
    tryRegisterHostForJN
    # 将 RM 写入host
    tryRegisterHostForRM
fi