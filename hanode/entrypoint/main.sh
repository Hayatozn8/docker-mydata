#!bin/bash
echo "--------------hanode-------------------"

# 缓存已经被写入过的 hosts
registeredHosts=()

# 缓存已经被写入过的 ssh 用户: user@hostname
registeredSSHUserHosts=()

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

# ssh 连接自己
function sshConnectSelf()
{
    # 获取当前 host 的 ip
    eval selfIP='$'$currentHost

    # 尝试将 self 的地址写入host
    tryRegisterHost $currentHost $selfIP

    # 尝试建立 ssh 连接
    tryRegisterSSHUserHost $currentHost "root"
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
        eval jnip='$'$jnHost

        tryRegisterHost $jnHost $jnip

        tryRegisterSSHUserHost $jnHost root
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
    # 1. 启动基本组件   
    # 注册zookeeper信息
    registerZkId
    # 启动 zk 集群
    zkServer.sh start

    # 2. 如果是main jn，即第一个 jn，则尝试启动整个 ha 集群
    tryStartMainJN
}

# 注册 zk 结点
function registerZkId()
{
    local jnList=$NN
    jnList=(${jnList//,/ })

    for (( i=0; i<${#jnList[@]}; i++ )); do
        if [ $currentHost = ${jnList[i]} ]; then
            echo "$[$i+1]" > /zkdata/myid
            return 0
        fi
    done
}

#  启动 RM 结点
function startRM()
{
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
    # 初始化 NN
    hdfs namenode -format
    # 启动hdfs
    start-dfs.sh
}

# ssh 连接 nn
function sshConnectNN()
{
    nHost=$NN
    eval nnip='$'$nHost
    # 尝试将 self 的地址写入host
    tryRegisterHost $nHost $nnip

    # 尝试建立 ssh 连接
    tryRegisterSSHUserHost $nHost "root"
}

function trySSHConnectNN2()
{
    nn2Host=$NN2
    if [ -n $nn2Host ]; then
        eval nn2ip='$'$nn2Host

        # 尝试将 self 的地址写入host
        tryRegisterHost $nn2Host $nn2ip

        # 尝试建立 ssh 连接
        tryRegisterSSHUserHost $nn2Host "root"
    fi
}

# 初始化 NN2
function initNN2()
{
    # 与自身建立 ssh 连接
    sshConnectSelf
    # 与 NN 建立连接
    sshConnectNN
}

# 初始化 RM
function initRM()
{
    # 与自身建立 ssh 连接
    sshConnectSelf
    # 与所有 slave 建立连接
    sshConnectSlaves
}

# 1. 获取当前的 hostname
currentHost=$(hostname)
# 2. 如果是NN
if [ $(isNNNode $currentHost) = 'y' ]; then
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
    initRM
    startRM
fi