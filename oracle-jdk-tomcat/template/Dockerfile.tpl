FROM registry.cn-hangzhou.aliyuncs.com/sourcegarden/jdk:%JVM_FLAVOUR%

ENV TOMCAT_MAJOR=%TOMCAT_MAJOR% \
    TOMCAT_VERSION=%TOMCAT_VERSION% \
    TOMCAT_HOME=/opt/tomcat \
    CATALINA_HOME=/opt/tomcat \
    CATALINA_OUT=/dev/null

RUN curl -jkSL -o /tmp/apache-tomcat.tar.gz https://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    gunzip /tmp/apache-tomcat.tar.gz && \
    tar -C /opt -xf /tmp/apache-tomcat.tar && \
    ln -s /opt/apache-tomcat-${TOMCAT_VERSION} ${TOMCAT_HOME}

RUN rm -rf ${TOMCAT_HOME}/webapps/*

COPY tomcat%TOMCAT_MAJOR%/logging.properties ${TOMCAT_HOME}/conf/logging.properties
COPY tomcat%TOMCAT_MAJOR%/server.xml ${TOMCAT_HOME}/conf/server.xml
COPY tomcat%TOMCAT_MAJOR%/tomcat-users.xml ${TOMCAT_HOME}/conf/tomcat-users.xml

VOLUME ["/logs"]

EXPOSE 8080
EXPOSE 8009
CMD ["/opt/tomcat/bin/catalina.sh", "run"]