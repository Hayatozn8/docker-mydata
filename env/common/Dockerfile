# docker build -t common-env ./hdnode
FROM centos:latest

# 添加docker环境变量
ENV DOCKERENV /dockerenv
ENV DOCKERENV_ENTRYPOINT $DOCKERENV/entrypoint
ENV DOCKERENV_CMD $DOCKERENV/cmd

# 添加 ll 指令
# 创建 entrypoint、cmd 分别保存docker启动时所需的sh
# entrypoint 默认由 entrypoint_default_start.sh 启动
# cmd 默认由 cmd_default_start.sh 启动
RUN echo "alias ll='ls -l'" >> /root/.bashrc \
    && mkdir -p $DOCKERENV \
    && mkdir -p $DOCKERENV_CMD \
    && touch $DOCKERENV_CMD/include \
    && touch $DOCKERENV_CMD/exclude \
    && mkdir -p $DOCKERENV_ENTRYPOINT \
    && touch $DOCKERENV_ENTRYPOINT/include \
    && touch $DOCKERENV_ENTRYPOINT/exclude

# 拷贝 sh，并设置权限
ADD sh/import.sh $DOCKERENV/import.sh
ADD sh/entrypoint_default_run.sh $DOCKERENV/entrypoint_default_run.sh
ADD sh/cmd_default_run.sh $DOCKERENV/cmd_default_run.sh

RUN chmod a+x $DOCKERENV/import.sh\
    && chmod a+x $DOCKERENV/entrypoint_default_run.sh\
    && chmod a+x $DOCKERENV/cmd_default_run.sh

# 执行默认的 entrypoint 启动文件
ENTRYPOINT [ "sh", "$DOCKERENV/entrypoint_default_run.sh" ]

# exec \"$DOCKERENV/entrypoint_default_run.sh\"