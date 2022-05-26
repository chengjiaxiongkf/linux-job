FROM bladex/alpine-java:openjdk8-openj9_cn_slim

MAINTAINER 514471552@qq.com

RUN mkdir -p /blade/xxljob-admin

WORKDIR /blade/xxljob-admin

EXPOSE 7009

ADD blade-xxljob-admin.jar ./app.jar

ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]
