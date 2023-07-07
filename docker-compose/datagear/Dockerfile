
FROM openjdk:8

ENV TZ=Asia/Shanghai

RUN ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
 
RUN mkdir -p /java

WORKDIR /java

ADD ./* ./

EXPOSE 50401
 
CMD java -Dserver.port=50401 -Xmx512m -Xms512m -Djava.security.egd=file:/dev/./urandom -jar datagear-4.6.0.jar
