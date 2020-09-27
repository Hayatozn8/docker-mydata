#!bin/bash
echo "--------------cmd-------------------"

# - 将slave的地址写入host
# - 搜索slave开始向所有salve发送ssh密钥
function sshConnectSlaves()
{
    # 获取所有slaves的id
    slaves=$SLAVES
    # 切分
    slaves=(${slaves//,/ }) 
    
    for slaveHostName in ${slaves[@]}
    do
        # 将slave的地址写入host
        eval slaveip='$'$slaveHostName
        echo "$slaveip  $slaveHostName" >> /etc/hosts
        # 搜索slave开始向所有salve发送ssh密钥
        sshpass -p '1234' ssh-copy-id -o StrictHostKeyChecking=no root@${slaveHostName} > /dev/null 2>&1
    done
}

function sshConnectNN()
{
    nnName=$NN
    eval nnip='$'$nnName
    echo "$nnip  $nnName" >> /etc/hosts
    
    sshpass -p '1234' ssh-copy-id -o StrictHostKeyChecking=no root@${nnName} > /dev/null 2>&1
}

function sshConnectNN2()
{
    nn2Name=$NN2
    eval nn2ip='$'$nn2Name
    echo "$nn2ip  $nn2Name" >> /etc/hosts

    sshpass -p '1234' ssh-copy-id -o StrictHostKeyChecking=no root@${nn2Name} > /dev/null 2>&1
}

# 1. 我是谁
hostname=$(hostname)
matched=0
# 2. 如果是NN
if [ "$hostname" = "$NN" ]; then
    sshConnectNN
    sshConnectNN2
    sshConnectSlaves
    # - 初始化 namenode
    hdfs namenode -format
    # - 启动namenode
fi

# 3. 如果是 NN2
if [ "$hostname" = "$NN2" ]; then
    sshConnectNN
    sshConnectNN2
fi

# 4. 如果是 RM
if [ "$hostname" = "$RM" ]; then
    sshConnectSlaves
    sshConnectNN
    sshpass -p '1234' ssh-copy-id -o StrictHostKeyChecking=no root@${hostname} > /dev/null 2>&1
    mkdir $HADOOP_HOME/logs
#     - 启动yarn
    start-all.sh
fi

# 5. 如果是slave
if [ "$matched" == '0' ]; then
    # - 将 NN 写入host
    nnName=$NN
    eval nnip='$'$nnName
    echo "$nnip  $nnName" >> /etc/hosts
        
    # - 将 RM 写入host
    rnName=$RN
    eval rnip='$'$rnName
    echo "$rnip  $rnName" >> /etc/hosts
fi

# keep alive
tail -f /dev/null