# DESCRIPTION:    Oracle Java jdk 8
# SOURCE:         https://github.com/airdock-io/docker-oracle-jdk

FROM airdock/base:jessie

# Add java dynamic memory script
COPY java-dynamic-memory-opts /srv/java/

# Install Oracle JDK 8
RUN cd /tmp && \
#    curl -L -O -H "Cookie: oraclelicense=accept-securebackup-cookie" -k "https://download.oracle.com/otn-pub/java/jdk/8u191-b12/2787e4a523244c269598db4e85c51e0c/jdk-8u191-linux-x64.tar.gz" && \
    curl -L -O -H "authorization":"Basic cGFud2VpOnBhbndlaUBkYW9jbG91ZA==" -k "https://www.itaojin.me/share/public/soft/jdk-8u191-linux-x64.tar.gz" && \
    tar xf jdk-8u191-linux-x64.tar.gz -C /srv/java && \
    rm -f jdk-8u191-linux-x64.tar.gz && \
    ln -s /srv/java/jdk* /srv/java/jdk && \
    ln -s /srv/java/jdk /srv/java/jvm && \
    chown -R java:java /srv/java && \
    /root/post-install

# Define commonly used JAVA_HOME variable
# Add /srv/java and jdk on PATH variable
ENV JAVA_HOME=/srv/java/jdk \
    PATH=${PATH}:/srv/java/jdk/bin:/srv/java
