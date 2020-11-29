FROM centos:latest

# 添加docker环境变量
ENV DOCKERENV /dockerenv
ENV DOCKERENV_ENTRYPOINT $DOCKERENV/entrypoint
ENV ENTRYPOINT_INCLUDE $DOCKERENV_ENTRYPOINT/include
ENV ENTRYPOINT_EXCLUDE $DOCKERENV_ENTRYPOINT/exclude

# 拷贝 import.sh
ADD src/add/import/import.sh $DOCKERENV/import.sh
ADD src/add/import/entrypoint_default_run.sh $DOCKERENV/entrypoint_default_run.sh
# 拷贝环境变量转配置的shell
ADD src/add/env2conf/env2conf.sh /usr/bin/env2conf.sh

# 添加 ll 指令
# 创建 entrypoint，保存docker启动时所需的sh
RUN echo "alias ll='ls -l'" >> /root/.bashrc \
    && chmod a+x $DOCKERENV/import.sh \
    && chmod a+x $DOCKERENV/entrypoint_default_run.sh \
    && chmod a+x /usr/bin/env2conf.sh

# 执行默认的 entrypoint 启动文件
ENTRYPOINT [ "/dockerenv/entrypoint_default_run.sh" ]