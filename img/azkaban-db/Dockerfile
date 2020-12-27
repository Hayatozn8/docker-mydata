FROM mysql:5.7

ARG pkg
ADD ${pkg} /opt/module/
ADD src/add/create_azkaban.sh /docker-entrypoint-initdb.d/

RUN mv /opt/module/azkaban* /opt/module/azkaban \
    && mv /opt/module/azkaban/create-all-sql*.sql /opt/module/azkaban/create-all-sql.sql