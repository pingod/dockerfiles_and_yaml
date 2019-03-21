FROM openjdk:8-jre

COPY sources.list /etc/apt/

RUN apt-get update && apt-get install -y procps \
    && wget "http://dl.mycat.io/1.6-RELEASE/Mycat-server-1.6-RELEASE-20161028204710-linux.tar.gz" -P /opt \
    && tar zxvf /opt/Mycat-server-1.6-RELEASE-20161028204710-linux.tar.gz -C /opt \
    && rm -fr /opt/Mycat-server-1.6-RELEASE-20161028204710-linux.tar.gz


EXPOSE 8066
#VOLUME ["/opt/mycat/conf"]

ENV MYCAT_HOME=/opt/mycat
ENV PATH=$PATH:$MYCAT_HOME/bin


COPY conf/ /opt/mycat/conf/
COPY entrypoint.sh /entrypoint.sh

#ENTRYPOINT ["/opt/mycat/bin/mycat", "console"]
ENTRYPOINT ["bash","-x","/entrypoint.sh"]
#CMD ["bash"]
