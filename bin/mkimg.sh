#!/bin/bash

# 接收imgID
imgID=$1

if [ -z "$imgID" ];then
    echo "mkdimg.sh error: imgID is empty"
    exit 1
fi

CMD_ROOT="$(cd `dirname $0`;pwd)/.."
IMG_DIR="$(cd $CMD_ROOT;pwd)/img"

# 检查imgID在img/下是否存在
if [ -d "$IMG_DIR/$imgID" ];then
    echo "mkimg.sh error: $IMG_DIR/$imgID is exists"
    exit 1
fi

# 创建:entrypoint/, entrypoint/main.sh, add/
mkdir -p "$IMG_DIR/$imgID/src/entrypoint"
echo '#!/bin/bash' > "$IMG_DIR/$imgID/src/entrypoint/main.sh"
mkdir -p "$IMG_DIR/$imgID/src/add"

# 创建 Dockerfile，将基本内容写入 Dockerfile
touch "$IMG_DIR/$imgID/Dockerfile"
cat>"$IMG_DIR/$imgID/Dockerfile"<<EOF
FROM <base-imgID>

# TODO
ARG pkg
ADD \${pkg} /opt/module/

# TODO
ADD src/entrypoint/main.sh \$DOCKERENV_ENTRYPOINT/${imgID}/main.sh

# TODO
RUN chmod a+x \$DOCKERENV_ENTRYPOINT/${imgID}/main.sh \\
 && echo "${imgID}" >> \$ENTRYPOINT_INCLUDE
EOF