FROM openjdk:8

MAINTAINER 514471552@qq.com

ENV TZ=Asia/Shanghai
ENV JAVA_OPTS="-XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Djava.security.egd=file:/dev/./urandom"
ENV JAVA_MEM_OPTIONS="-Xmx512m -Xms512m -Xss512K"
ENV NACOS_ID=""
ENV NACOS_IP=""
ENV NACOS_PORT=""
ENV NACOS_GROUP=""
ENV NACOS_USERNAME=""
ENV NACOS_PASSWORD=""

RUN ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN mkdir -p /java

WORKDIR /java

EXPOSE 108

ADD ./target/gift-base-boot.jar ./

CMD java -Dspring.cloud.nacos.discovery.server-addr=$NACOS_IP:$NACOS_PORT -Dspring.cloud.nacos.discovery.namespace=$NACOS_ID -Dspring.cloud.nacos.discovery.group=$NACOS_GROUP -Dspring.cloud.nacos.discovery.username=$NACOS_USERNAME -Dspring.cloud.nacos.discovery.password=$NACOS_PASSWORD $JAVA_OPTS $JAVA_MEM_OPTIONS -jar gift-base-boot.jar