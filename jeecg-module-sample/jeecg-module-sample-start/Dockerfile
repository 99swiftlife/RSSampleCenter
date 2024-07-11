FROM anapsix/alpine-java:8_server-jre_unlimited

MAINTAINER swiftlife

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

RUN mkdir -p /classify-service

WORKDIR /sample-service

EXPOSE 7010

ADD ./target/jeecg-module-sample-start.jar ./

CMD sleep 1;java -Dfile.encoding=utf-8 -Djava.security.egd=file:/dev/./urandom -jar jeecg-module-sample-start.jar
