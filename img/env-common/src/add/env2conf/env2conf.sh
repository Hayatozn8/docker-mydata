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
    cat << USAGE >&1
Usage:
    env2conf.sh -e envPrefix -c confPath [options]
    -e envPrefix  | --envPrefix=envPrefix   evn startkey
    -c confPath   | --conf=confPath         config path

Options:
    -i include    | --include=include       [list] only use the element of include list
    -x exclude    | --exclude=exclude       [list] will not write to config
    -t [txt,xml]  | --type=[txt,xml]        type of conf, default type is [txt]
    -d delimiter  | --delimiter=delimiter   delimiter of confkey confValue, default type is [=]
                  | --xmlTemplate=...       when -t/--type is xml, must set xmlTemplate !!!
                                            example:
                                                <property><name>@key@</name><value>@value@</value></property>
                                            @key@, @value@ will be repalced by env
                  | --xmlAppendTo=...       when -t/--type is xml, must set xmlAppendTo !!!
                                            example:
                                                configuration
                                            after replaced key and value of xmlTemplate,
                                            will append the replaced string to config before the tag
                                            set with xmlAppendTo
                                            append example:
                                                <configuration>
                                                    <property><name>xxx</name><value>yyy</value></property>
                                                </configuration>
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


function envToConf(){
    # 获取环境变量中以 $envPrefix 参数开头的所有变量
    envNameList=($(env | grep -E "^${envPrefix}_.*${kvDelimiter}" | cut -d "=" -f 1))

    # 向指定的配置文件中写入一个换行
    # 防止配置文件不是以换行结尾时，导致的配置写入异常
    if [ ${#envNameList[@]} != 0 ];then
        echo -e "\n" >> $confPath
    fi

    # 迭代环境变量，并写入 $confPath 指定的配置文件
    for envName in ${envNameList[@]}; do
        # KAFKA_LOG_DIRS=/opt ---> LOG_DIRS ---> log_dirs ---> log.dirs
        confKey=$(echo ${envName#$envPrefix\_} | sed 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/' | sed 's/_/./g')

        # 检查是否需要将当前key写入配置
        if [ $(isInclude $confKey) = 'n' ]; then
            continue
        fi

        # log_dirs=/opt ---> /opt
        confValue=${!envName}

        # env to conf
        eval "${type}PropertyWrite" '"$confKey"' '"$confValue"'
    done
}

# write evn to txt_config
# @param $1 key
# @param $2 value
function txtPropertyWrite(){
    tmpKVDelimiter=${kvDelimiter//\//\\/}
    # 检索行号，只取第一个
    rowNo=$(grep -ne "^$1${tmpKVDelimiter}.*$" $confPath | head -n 1 | cut -d ':' -f 1)

    if [ -z $rowNo ];then
        # 如果某个属性不存在，则直接添加
        echo "$1$kvDelimiter$2" >> $confPath
    else
        # 如果某个属性已经存在，则直接覆盖
        # 转译 / 为 \/，防止 sed 异常
        confValue=${2//\//\\\/}
        sed -i "$rowNo""c $1${tmpKVDelimiter}${confValue}" $confPath
    fi
}

# write evn to xml_config
# @param $1 key
# @param $2 value
function xmlPropertyWrite(){
    local key=$1
    local value=${2//\//\\\/}
    value=${value//&/\\&}

    local entry=$( echo "$xmlTemplate" | sed "s/@key@/${key}/" | sed "s/@value@/${value}/" )
    entry=${entry//\//\\/}
    entry=${entry//&/\\&}

    sed -i "/<\/${xmlAppendTo}>/ s/.*/${entry}\n&/" $confPath
}
###################### main ######################
# 1. get option
type=""
envPrefix=""
confPath=""
include=()
exclude=()
kvDelimiter=""
xmlTemplate=""
xmlAppendTo=""
while [ $# -gt 0 ]
do
    case "$1" in
        # --envPrefix -e
        -e)
            envPrefix="$2"
            if [ -z $envPrefix ]; then
                echoerr "env2vonf.sh error: -e is empty"
                exit 1
            fi
            consumeParamCount=2
        ;;
        --envPrefix=*)
            envPrefix="${1#*=}"
            if [ -z $envPrefix ]; then
                echoerr "env2vonf.sh error: --envPrefix is empty"
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
            if [ -z $envPrefix ]; then
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
        # xml parameter
        --xmlTemplate=*)
            xmlTemplate="${1#*=}"
            consumeParamCount=1
        ;;
        --xmlAppendTo=*)
            xmlAppendTo="${1#*=}"
            consumeParamCount=1
        ;;
        # other
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

# 2. check options
if [ -z $confPath ]; then
    echoerr "env2vonf.sh error: -c/--conf is empty"
    exit 1
fi

if [ -z $envPrefix ]; then
    echoerr "env2vonf.sh error: -e/--envPrefix is empty"
    exit 1
fi

type=${type:-txt}
if [ "$type" != "txt" -a "$type" != "xml" ]; then
    echoerr "env2vonf.sh error: type = $type. type must be txt or xml"
    exit 1
fi

if [ "$type" = "xml" -a -z "$xmlTemplate" ]; then
    echoerr "env2vonf.sh error: when type is xml. --xmlTemplate must be set"
    exit 1
fi

if [ "$type" = "xml" -a -z "$xmlAppendTo" ]; then
    echoerr "env2vonf.sh error: when type is xml. --xmlAppendTo must be set"
    exit 1
fi

kvDelimiter=${kvDelimiter:-=}

# 3. check confPath
if [ ! -f "$confPath" ];then
    touch $confPath
    echo "env2vonf.sh info: can't find $confPath, touched"
fi

# 4. evn to config
envToConf