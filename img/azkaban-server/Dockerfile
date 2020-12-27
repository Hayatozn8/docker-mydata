# FROM env-jdk8
FROM hbase-hive

ARG web_pkg
ARG executor_pkg
ADD ${web_pkg} /opt/module/azkaban/
ADD ${executor_pkg} /opt/module/azkaban/

ADD src/entrypoint/main.sh $DOCKERENV_ENTRYPOINT/azkaban/main.sh

RUN mv /opt/module/azkaban/azkaban-web* /opt/module/azkaban/web \
    && mv /opt/module/azkaban/azkaban-executor* /opt/module/azkaban/executor \
    && chmod a+x $DOCKERENV_ENTRYPOINT/azkaban/main.sh \
    && echo 'azkaban' >> $ENTRYPOINT_INCLUDE