
FROM openjdk:8

ENV TZ=Asia/Shanghai

RUN ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
 
RUN mkdir -p /java
 
WORKDIR /java
 
EXPOSE 7100
 
ADD ./app.jar ./
 
CMD java -Dserver.port=7100 -Xmx512m -Xms512m -Dspring.profiles.active=prod -Djava.security.egd=file:/dev/./urandom -jar app.jar
