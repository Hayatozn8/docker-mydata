#!/bin/bash

# env2conf.sh -e ZOO \
#             -c $ZOOKEEPER_HOME/conf/zoo.cfg \
#             -t 'text' \
#             -d "=" \
#             -i "aaa" \
#             -i "bbb" \
#             -x "my.id"
#             -x "rrrr"

function usage()
{
    cat << USAGE >&2
Usage:
    env2conf.sh -e evnStartkey -c confPath [options]
    -e evnStartKey| --evnStart=evnStartKey  evn startkey
    -c confPath   | --conf=confPath         config path

Options:
    -i include    | --include=include       [list] only use the element of include list
    -x exclude    | --exclude=exclude       [list] will not write to config
    -t [txt,xml]  | --type=[txt,xml]        type of conf, default type is `txt`
    -d delimiter  | --delimiter=delimiter   delimiter of confkey confValue, default type is `=`

USAGE
}


function echoerr() {
    echo "$@" 1>&2
}

# 检查是否需要将当前配置添加到配置文件
# isInclude "xxx"
# @param $1, confKey
# @return 'y' --> include, 'n' --> exclude
function isInclude(){
    # 如果指定了 include，则只能添加 include 中的配置
    if [ ${#include[@]} != 0 ]; then
        # 如果找到则返回true
        for in in ${include[@]};do
            if [ $in = $1 ]; then
                echo 'y'
                return
            fi
        done
        echo "n"
        return 
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

function writeTxtConf(){
    # 获取环境变量中以 $evnStart 参数开头的所有变量
    envNameList=($(env | grep -E "^${evnStart}_.*${kvDelimiter}" | cut -d "=" -f 1))

    # 向指定的配置文件中写入一个换行
    # 防止配置文件不是以换行结尾时，导致的配置写入异常
    if [ ${#envNameList[@]} != 0 ];then
        echo -e "\n" >> $confPath
    fi

    # 迭代环境变量，并写入 $confPath 指定的配置文件
    for envName in ${envNameList[@]}; do
        # KAFKA_LOG_DIRS=/opt ---> LOG_DIRS ---> log_dirs ---> log.dirs
        # confKey=$(echo $envName | sed -E "s/^${evnStart}_(.*)/\1/") | sed 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/' | sed 's/_/./g')
        confKey=$(echo $envName | sed "s/${evnStart}_//" | sed 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/' | sed 's/_/./g')
        # 检查是否需要将当前key写入配置
        if [ $(isInclude $confKey) = 'n' ]; then
            continue
        fi

        # log_dirs=/opt ---> /opt
        eval confValue='$'$envName

        rowNo=$(grep -ne "^${confKey}${tmpKVDelimiter}.*$" $confPath | head -n 1| cut -d ':' -f 1)
        if [ -z $rowNo ];then
            # 如果某个属性不存在，则直接添加
            echo "$confKey$kvDelimiter$confValue" >> $confPath
        else
            # 如果某个属性已经存在，则直接覆盖
            # 转译 / 为 \/，防止 sed 异常
            confValue=${confValue//\//\\/}
            tmpKVDelimiter=${kvDelimiter//\//\\/}
            sed -i "$rowNo""c ${confKey}${tmpKVDelimiter}${confValue}" $confPath
        fi
    done
}


###################### main ######################
# extract parameters
type=""
evnStart=""
confPath=""
include=()
exclude=()
kvDelimiter=""
while [ $# -gt 0 ]
do
    case "$1" in
        # --evnStart -e
        -e)
            evnStart="$2"
            if [ -z $evnStart ]; then
                echoerr "env2vonf.sh error: -e is empty"
                exit 1
            fi
            consumeParamCount=2
        ;;
        --evnStart=*)
            evnStart="${1#*=}"
            if [ -z $evnStart ]; then
                echoerr "env2vonf.sh error: --evnStart is empty"
                exit 1
            fi
            consumeParamCount=1
        ;;
        # --conf -c
        -c)
            confPath="$2"
            if [ -z $confPath ]; then
                echoerr "env2vonf.sh error: -c is empty"
                exit 1
            fi
            consumeParamCount=2
        ;;
        --conf=*)
            confPath="${1#*=}"
            if [ -z $evnStart ]; then
                echoerr "env2vonf.sh error: --conf is empty"
                exit 1
            fi
            consumeParamCount=1
        ;;
        # --type -t
        -t)
            type="$2"
            if [ -z $type ]; then
                echoerr "env2vonf.sh error: -t is empty"
                exit 1
            fi
            consumeParamCount=2
        ;;
        --type=*)
            type="${1#*=}"
            if [ -z $type ]; then
                echoerr "env2vonf.sh error: --type is empty"
                exit 1
            fi
            consumeParamCount=1
        ;;
        # --include -i
        -i)
            if [ ! -z "$2" ]; then
                include[${#include[@]}]="$2"
            fi
            consumeParamCount=2
        ;;
        --include=*)
            temp="${1#*=}"
            if [ ! -z $temp ]; then
                include[${#include[@]}]=$temp
            fi
            consumeParamCount=1
        ;;
        # --exclude -x
        -x)
            if [ ! -z "$2" ]; then
                exclude[${#exclude[@]}]="$2"
            fi
            consumeParamCount=2
        ;;
        --exclude=*)
            temp="${1#*=}"
            if [ ! -z $temp ]; then
                exclude[${#exclude[@]}]=$temp
            fi
            consumeParamCount=1
        ;;
        # --delimiter -d
        -d)
            kvDelimiter="$2"
            if [ -z $kvDelimiter ]; then
                echoerr "env2vonf.sh error: -d is empty"
                exit 1
            fi
            consumeParamCount=2
        ;;
        --delimiter=*)
            kvDelimiter="${1#*=}"
            if [ -z $kvDelimiter ]; then
                echoerr "env2vonf.sh error: --delimiter is empty"
                exit 1
            fi
            consumeParamCount=1
        ;;
        --help)
            usage
            exit 0
        ;;
        *)
            echoerr "env2vonf.sh error: Unknown argument: $1"
            usage
            exit 1
        ;;
    esac

    if [ $consumeParamCount -gt $# ]; then
        break
    fi

    shift $consumeParamCount
done

if [ -z $confPath ]; then
    echoerr "env2vonf.sh error: -c/--conf is empty"
    exit 1
fi

if [ -z $evnStart ]; then
    echoerr "env2vonf.sh error: -e/--evnStart is empty"
    exit 1
fi

type=${type:-txt}
if [ $type != "txt" -a $type != 'xml' ]; then
    echoerr "env2vonf.sh error: type = $type. type must be txt or xml"
    exit 1
fi

kvDelimiter=${kvDelimiter:-=}

# check confPath
if [ ! -f $confPath ];then
    touch $confPath
    echo "env2vonf.sh info: can't find $confPath, touched"
fi

# env to conf
if [ $type = "txt" ];then
    writeTxtConf
fi