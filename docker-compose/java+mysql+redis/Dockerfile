FROM registry.cn-zhangjiakou.aliyuncs.com/cjx_common/openjdk:8

MAINTAINER 514471552@qq.com

ENV TZ=Asia/Shanghai
ENV JAVA_OPTS="-XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Djava.security.egd=file:/dev/./urandom"
ENV JAVA_MEM_OPTIONS="-Xmx1g -Xms1g -Xss512K"
ENV PROFILE_ENV=""

RUN ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN mkdir -p /java

WORKDIR /java

EXPOSE 8085

ADD ../target/stonedt-portal-0.5.3-SNAPSHOT.jar ./
ADD ../config ./

CMD java -Dspring.profiles.active=$PROFILE_ENV $JAVA_OPTS $JAVA_MEM_OPTIONS -jar stonedt-portal-0.5.3-SNAPSHOT.jar
