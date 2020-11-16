#!/bin/bash

# - 调用
#     - 输入全部参数
#         - evn2conf.sh envStartStr confFilePath kvDelimiter "include1,include2" "exclude1,exclude2,exclude3"
#     - 只使用 envStartStr confFilePath，kvDelimiter使用默认值，不设置include、exclude列表
#         - 设置所有参数
#             - evn2conf.sh envStartStr confFilePath "" "" ""
#         - 简便写法
#             - evn2conf.sh envStartStr confFilePath
#     - 单独设置 kvDelimiter
#         - evn2conf.sh envStartStr confFilePath ":"
# - 功能
#     - 获取环境变量中以指定字符串开头的所有变量，并添加到指定的配置文件中
#     - 要求环境变量
#         1. 以指定的字符串开头，后跟一个`_`，如: KAFKA_
#         2. 所有配置的key中的 `.` 替换成 `_`，如: KAFKA_LOG_DIRS
# - 参数
#     - delimit
#         - 表示key、value之间的分隔符
#         - "", 使用默认值 `=`
#     - include
#         - 指定只作为配置的key，只指定key，不需要指定环境变量
#         - "" 表示所有能找到的环境变量都作为配置
#         - 多个key以 `,` 分割，如"xxx.a,xxx.b"
#     - exclude
#         - 指定需要排除的key
#         - "" 表示所有能找到的环境变量都作为配置
#         - 多个key以 `,` 分割，如"xxx.a,xxx.b"

# 设置参数
envStartStr=$1
confFilePath=$2
if [ -z $3 ];then
    kvDelimiter="="
else
    kvDelimiter=$3
fi
include=$4
include=(${include//,/ })
exclude=$5
exclude=(${exclude//,/ })

function isInclude(){
    if [ ${#include[@]} != 0 ]; then
        # 如果数量不等于0，则检查是否需要包含
        for in in ${include[@]};do
            if [ $in = $1 ]; then
                echo 'y'
                return
            fi
        done
    fi

    # 检查是否需要排除
    if [ ${#exclude[@]} != 0 ]; then
        for ex in ${exclude[@]};do
            if [ $ex = $1 ]; then
                echo 'n'
                return
            fi
        done
    fi

    echo 'y'
}


# 获取环境变量中以 $envStartStr 参数开头的所有变量
envNameList=($(env | grep -E "^${envStartStr}_.*${kvDelimiter}" | cut -d "=" -f 1))

# 向指定的配置文件中写入一个换行
# 防止配置文件不是以换行结尾时，导致的配置写入异常
if [ ${#envNameList[@]} != 0 ];then
    echo -e "\n" >> $confFilePath
fi

# 迭代环境变量，并写入 $confFilePath 指定的配置文件
for envName in ${envNameList[@]}; do
    # KAFKA_LOG_DIRS=/opt ---> LOG_DIRS ---> log_dirs ---> log.dirs
    # confKey=$(echo $envName | sed -E "s/^${envStartStr}_(.*)/\1/") | sed 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/' | sed 's/_/./g')
    confKey=$(echo $envName | sed "s/${envStartStr}_//" | sed 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/' | sed 's/_/./g')
    # 检查是否需要将当前key写入配置
    if [ $(isInclude $confKey) = 'n' ]; then
        continue
    fi

    # log_dirs=/opt ---> /opt
    eval confValue='$'$envName

    rowNo=$(grep -ne "^${confKey}${tmpKVDelimiter}.*$" $confFilePath | head -n 1| cut -d ':' -f 1)
    if [ -z $rowNo ];then
        # 如果某个属性不存在，则直接添加
        echo "$confKey$kvDelimiter$confValue" >> $confFilePath
    else
        # 如果某个属性已经存在，则直接覆盖
        # 转译 / 为 \/，防止 sed 异常
        confValue=${confValue//\//\\/}
        tmpKVDelimiter=${kvDelimiter//\//\\/}
        sed -i "$rowNo""c ${confKey}${tmpKVDelimiter}${confValue}" $confFilePath
    fi
done