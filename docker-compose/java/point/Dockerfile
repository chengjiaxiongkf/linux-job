FROM bladex/alpine-java:openjdk8-openj9_cn_slim

MAINTAINER 514471552@qq.com

RUN mkdir -p /java

WORKDIR /java

EXPOSE 19999

ADD point.jar ./point.jar

ENV ENV="vm"
ENV JAVA_NAME="point"
ENV JAVA_OPTS="-Xmx512m -Xms512m -Xss512k"
ENV AGENT_PATH="/java/skywalking/skywalking-agent.jar"
ENV AGENT_SERVICES="192.168.152.128:11800"

CMD java -javaagent:${AGENT_PATH} -Dskywalking.collector.backend_service=${AGENT_SERVICES} -Dskywalking.agent.service_name=${JAVA_NAME} ${JAVA_OPTS} -Dspring.profiles.active=${ENV} -Dserver.port=19999 -Djava.security.egd=file:/dev/./urandom -jar ${JAVA_NAME}.jar
#ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]