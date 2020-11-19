#!/bin/bash

#### 调用方法 ####
# sh import.sh entrypoint
# 第一参数必须指定为 $DOCKERENV 下的工作目录

# 0. 检查 $1 是否为空
if [ -z "$1" ]; then
    echo "Please set the directory on the first parameter"
    exit 1000
fi

# 5. 设置任务目录
WORK_DIR="$DOCKERENV/$1"
INCLUDE_FILE="$DOCKERENV/$1/include"
EXCLUDE_FILE="$DOCKERENV/$1/exclude"

# 1. 如果 include 不存在，则退出
if [ ! -f "$INCLUDE_FILE" ]; then
    echo "import.sh: $INCLUDE_FILE  is not exist，import has been stopped"
    exit 0
fi

# 2. 读取需要包含的内容到数组
includes=( $(cat "$INCLUDE_FILE") )

# 3. 如果 include 为空，则不进行处理
if [ ${#includes[@]} -eq 0 ]; then
    echo "import.sh: $INCLUDE_FILE  is empty，import has been stopped"
    exit 0
fi

# 4. 如果 exclude 存在，则读取
if [ -f "$EXCLUDE_FILE" ]; then
    excludes=( $(cat "$EXCLUDE_FILE") )
else
    excludes=()
fi

# 6. 从 includes 中删除 excludes
# 如果 excludes 是空的(len == 0)，则跳过
# - 如果 includes 在 excludes 中则删除
epList=()
# 1=需要包含; 0=不需要包含
isInclude=1
if [ ${#excludes[@]} -ne 0 ]; then
    for e in ${includes[@]}; do
        isInclude=1
        for (( i=0; i<${#excludes[@]}; i++ )); do
            if [ "$e" = "${excludes[i]}" ]; then
                isInclude=0
                break
            fi
        done

        if [ $isInclude -eq 1 ]; then
            epList[${#epList[@]}]="$e"
        fi
    done
else
    epList=(${includes[@]})
fi

# 7. 检查includes中的目录是否存在，同时转换成可执行的目录
# - 如果是空行，cat 转数组时，会自动忽略
# - 如果 $WORK_DIR/xxx = 目录
#   - 如果 $WORK_DIR/xxx/main.sh 存在，则添加到 runList 数组中，跳出当次遍历
# - 如果 $WORK_DIR/xxx = 文件
#   - 将 $WORK_DIR/xxx 添加到 runList 数组中，跳出当次遍历
# - 如果还没有找到，尝试: xxx = 是已存在的文件，则执行
# - 否则没有找到，则异常

runList=()
for ep in ${epList[@]}; do
    if [ -d "$WORK_DIR/$ep" ]; then
        if [ -f "$WORK_DIR/$ep/main.sh" ]; then
            runList[${#runList[@]}]="$WORK_DIR/$ep/main.sh"
            continue
        fi
    elif [ -f "$WORK_DIR/$ep" ]; then
            runList[${#runList[@]}]="$WORK_DIR/$ep"
            continue
    fi

    if [ -f "$ep" ]; then
        runList[${#runList[@]}]="$ep"
        continue
    else
        echo "can't find file: '$ep' or '$WORK_DIR/$ep/main.sh'"
        exit 1001
    fi
done

# 4. 按顺序执行所有的 sh
for path in ${runList[@]}; do
    sh "$path"
done
