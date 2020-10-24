#!bin/bash

#### 调用方法 ####
# sh import.sh entrypoint
# 第一参数必须指定为 $DOCKERENV 下的工作目录

# 0. 检查 $1 是否为空
if [ -z $1 ]; then
    echo "Please set the directory on the first parameter"
    exit 1000
fi

# 1. 读取需要包含的内容到数组
includes=( $(cat $DOCKERENV/$1/include) )

# 2. 如果 include 为空，则不进行处理
if [ ${#includes[@]} -eq 0 ]; then
    echo "'$DOCKERENV/$1/include' is empty，import has been skipped"
    exit 0
fi

# 3. 读取不需要包含的内容到数组
excludes=( $(cat $DOCKERENV/$1/exclude) )

# 4. 设置任务目录
TASK_DIR="$DOCKERENV/$1"

# 4. 从 includes 中删除 excludes
# 如果 excludes 是空的(len == 0)，则跳过
# - 如果 includes 在 excludes 中则删除
needs=()
# 1=需要包含; 0=不需要包含
isInclude=1
if [ ${#excludes[@]} -ne 0 ]; then
    for e in ${includes[@]}; do
        isInclude=1
        for (( i=0; i<${#excludes[@]}; i++ )); do
            if [ $e = ${excludes[i]} ]; then
                isInclude=0
                break
            fi
        done

        if [ $isInclude -eq 1 ]; then
            needs[${#needs[@]}]="$e"
        fi
    done
else
    needs=(${includes[@]})
fi

# 3. 检查includes中的目录是否存在，同时转换成可执行的目录
# - 如果是空行，cat 转数组时，会自动忽略
# - if: 如果 $TASK_DIR/xxx = 目录
#   - 如果 $TASK_DIR/xxx/main.sh 存在，则添加到 runList 数组中，跳出当次遍历
# - if: 如果 $TASK_DIR/xxx = 文件
#   - 将 $TASK_DIR/xxx 添加到 runList 数组中，跳出当次遍历
# - 如果还没有找到，尝试: xxx = 是已存在的文件，则执行
# - 否则没有找到，则异常

runList=()
# runList[${#runList[@]}]=value
for e in ${needs[@]}; do
    if [ -d "$TASK_DIR/$e" ]; then
        if [ -f "$TASK_DIR/$e/main.sh" ]; then
            runList[${#runList[@]}]="$TASK_DIR/$e/main.sh"
            continue
        fi
    elif [ -f "$TASK_DIR/$e" ]; then
            runList[${#runList[@]}]="$TASK_DIR/$e"
            continue
    fi

    if [ -f "$e" ]; then
        runList[${#runList[@]}]="$e"
        continue
    else
        echo "can't find file: '$e' or '$TASK_DIR/$e/main.sh'"
        exit 1001
    fi
done

# 4. 按顺序执行所有的 sh
for p in ${runList[@]}; do
    sh $p
done
