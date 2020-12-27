#!/bin/bash

mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" < /opt/module/azkaban/create-all-sql.sql