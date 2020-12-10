#!/bin/bash
echo "--------------hanode-------------------"

# 写入配置
echo "write core-site.xml"
env2conf.sh -e HA_CORE -t xml -c $HADOOP_HOME/etc/hadoop/core-site.xml \
            --xmlTemplate='<property><name>@key@</name><value>@value@</value></property>' \
            --xmlAppendTo=configuration

echo "write hdfs-site.xml"
env2conf.sh -e HA_HDFS -t xml -c $HADOOP_HOME/etc/hadoop/hdfs-site.xml \
            --xmlTemplate='<property><name>@key@</name><value>@value@</value></property>' \
            --xmlAppendTo=configuration

echo "write yarn-site.xml"
env2conf.sh -e HA_YARN -t xml -c $HADOOP_HOME/etc/hadoop/yarn-site.xml \
            --xmlTemplate='<property><name>@key@</name><value>@value@</value></property>' \
            --xmlAppendTo=configuration

echo "write mapred-site.xml"
cp $HADOOP_HOME/etc/hadoop/mapred-site.xml.template $HADOOP_HOME/etc/hadoop/mapred-site.xml
env2conf.sh -e HA_MR -t xml -c $HADOOP_HOME/etc/hadoop/mapred-site.xml \
            --xmlTemplate='<property><name>@key@</name><value>@value@</value></property>' \
            --xmlAppendTo=configuration


# 检查是不是 ha 环境
# 多个 nn 返回 y
# 一个 nn 返回 n
function isHaEnv()
{
    local jnList=$NN
    jnList=(${jnList//,/ })

    if [ ${#jnList[@]} -eq 1 ]; then
        echo "n"
    else
        echo "y"
    fi
}

# 尝试将 ip、hostname 写入 /etc/hosts
# $1 ip
# $2 hostname
function tryRegisterHost()
{
    # 如果从未写入过 /etc/hosts，则写入
    if [ -z  $(grep "$1\s+$2$" /etc/hosts) ]; then
        echo "$1 $2" >> /etc/hosts
    fi
}

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

# 将 slave 的地址写入host
# 搜索 slave 开始向所有salve发送ssh密钥
function sshConnectSlaves()
{
    # 获取所有 slaves 的 id
    local slaves=$SLAVES
    slaves=(${slaves//,/ })

    for slaveHostName in ${slaves[@]}
    do
        # 通过HostName从环境变量中获取对应的IP
        eval slaveIP='$'$slaveHostName

        # 尝试将 slave 的地址写入host
        tryRegisterHost $slaveIP $slaveHostName

        # 尝试建立 ssh 连接
        tryCreateSSHConnect "root" $slaveHostName
    done
}

# ssh 连接自己
function sshConnectSelf()
{
    # 获取当前 host 的 ip
    eval selfIP='$'$currentHost

    # 尝试将 self 的地址写入host
    tryRegisterHost $selfIP $currentHost

    # 尝试建立 ssh 连接
    tryCreateSSHConnect "root" $currentHost
}

# -----------------------------------------------
# 多个 nn 结点的 ha 集群

# 尝试用 ssh 连接所有的 JN
function sshConnectJN()
{
    local jnList=$NN
    jnList=(${jnList//,/ })

    for jnHost in ${jnList[@]}
    do
        # 通过HostName从环境变量中获取对应的IP
        eval jnip='$'$jnHost

        tryRegisterHost $jnip $jnHost

        tryCreateSSHConnect "root" $jnHost
    done
}

# 检查结点是否为 NN
function isNNNode()
{
    # 为了兼容 nn 和 jn 的两种部署，全部通过遍历数组来判断
    local hostname=$1
    # 获取所有JN的id
    local jnList=$NN
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

# 尝试启动 第一个mainJN节点，即NN中的第一个JN节点
function tryStartMainJN()
{
    # 获取所有JN的id
    local jnList=$NN
    jnList=(${jnList//,/ })

    # 1. 检查 hostname 是不是mani JN 节点 (即 NN 的第一个节点)
    # 如果不是则返回
    if [ $currentHost != ${jnList[0]} ]; then
        return 0
    fi

    # 2. 启动整个高可用集群
    # 启动 JN 结点
    for jsHost in ${jnList[@]}
    do
        ssh "root@${jsHost}" $HADOOP_HOME/sbin/hadoop-daemon.sh start journalnode
    done

    # 格式化 nn
    hdfs namenode -format
    # 启动当前nn结点
    ssh "root@${currentHost}" $HADOOP_HOME/sbin/hadoop-daemon.sh start namenode

    # 当前结点之外的 JN 结点拷贝元数据
    for (( i=0; i<${#jnList[@]}; i++ )); do
        if [ $i -ne 0 ]; then
            # 同步元数据
            ssh "root@${jnList[i]}" $HADOOP_HOME/bin/hdfs namenode -bootstrapStandby
        fi
    done

    # 初始化 HA 在 Zookeeper 中状态
    hdfs zkfc -formatZK

    # 群起
    start-dfs.sh
}

# 初始化 JN 结点
function initJN()
{
    echo "...init JN..."
    # 与自身建立 ssh 连接
    sshConnectSelf
    # 与所有 slave 建立连接
    sshConnectSlaves
    # 与其他 JN 互联
    sshConnectJN
}

#  启动 JN 结点
function startJN()
{
    echo "...start JN..."
    # 1. 需要设置 ZOO_MY_ID，zk集群将会自动启动
    # 2. 如果是main jn，即第一个 jn，则尝试启动整个 ha 集群
    tryStartMainJN
}

#  启动 RM 结点
function startRM()
{
    echo "...start RM..."
    # 创建日志目录
    mkdir $HADOOP_HOME/logs
    # 启动 yarn
    start-yarn.sh
}

# ------------------------------------------------
# 只有一个 NN 结点的普通集群

# 初始化 NN 结点
function initNN()
{
    echo "...init NN..."
    # 与自身建立 ssh 连接
    sshConnectSelf
    # 与所有 slave 建立连接
    sshConnectSlaves
    # 尝试连接 NN2
    trySSHConnectNN2
}

# 启动 NN
function startNN()
{
    echo "...start NN..."
    # 初始化 NN
    hdfs namenode -format
    # 启动hdfs
    start-dfs.sh
}

# ssh 连接 nn
function sshConnectNN()
{
    echo "...connect NN by ssh..."

    nHost=$NN
    eval nnip='$'$nHost
    # 尝试将 self 的地址写入host
    tryRegisterHost $nnip $nHost

    # 尝试建立 ssh 连接
    tryRegisterSSHUserHost $nHost "root"
}

function trySSHConnectNN2()
{
    echo "...connect NN2 by ssh..."
    
    if [ ! -z $NN2 ]; then
        eval nn2ip='$'$NN2

        # 尝试将 self 的地址写入host
        tryRegisterHost $nn2ip $NN2

        # 尝试建立 ssh 连接
        tryRegisterSSHUserHost $NN2 "root"
    fi
}

# 初始化 NN2
function initNN2()
{
    echo "...init NN2..."

    # 与自身建立 ssh 连接
    sshConnectSelf
    # 与 NN 建立连接
    sshConnectNN
}

# 初始化 RM
function initRM()
{
    echo "...init RM..."

    # 与自身建立 ssh 连接
    sshConnectSelf
    # 与所有 slave 建立连接
    sshConnectSlaves
}

function writeSlaves()
{
    echo 'write etc/hadoop/slaves'
    # 获取所有 slaves 的 id
    local slaves=$SLAVES
    slaves=(${slaves//,/ })

    >$HADOOP_HOME/etc/hadoop/slaves
    for slaveName in ${slaves[@]};do
        echo $slaveName >> $HADOOP_HOME/etc/hadoop/slaves
    done
}

# ----------------- main() ------------------
# 1. 获取当前的 hostname
currentHost=$(hostname)
# 2. 如果是NN
if [ $(isNNNode $currentHost) = 'y' ]; then
    # 写入 slaves 文件
    writeSlaves

    if [ $(isHaEnv) = 'y' ]; then
        # ha 环境配置
        initJN
        startJN
    else
        initNN
        startNN
    fi
fi

# 3. 如果是 NN2，只初始化，由NN负责启动
if [ "$currentHost" = "$NN2" ]; then
    initNN2
fi

# 4. 如果是 RM，初始化并启动
if [ "$currentHost" = "$RM" ]; then
    # 写入 slaves 文件
    writeSlaves
    
    initRM
    startRM
fi