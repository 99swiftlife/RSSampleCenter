FROM postgis/postgis

#MAINTAINER swiftlife

ENV TZ=Asia/Shanghai

RUN ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY postgre-init.sql /docker-entrypoint-initdb.d
