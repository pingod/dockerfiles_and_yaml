FROM maven:3.5.4-jdk-7

ARG USER_HOME_DIR="/root"

COPY ../settings-public-aliyun.xml /usr/share/maven/ref/
#COPY ../settings-inside-nexus.xml /usr/share/maven/ref/

#VOLUME "$USER_HOME_DIR/.m2"

CMD ["mvn"]
