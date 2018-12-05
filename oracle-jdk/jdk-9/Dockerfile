# DESCRIPTION:    Oracle Java jdk 9
# SOURCE:         https://github.com/airdock-io/docker-oracle-jdk

FROM airdock/base:jessie

# Add java dynamic memory script
COPY java-dynamic-memory-opts /srv/java/

# Install Oracle JDK 9
RUN cd /tmp && \
    curl -L -O -H "authorization":"Basic cGFud2VpOnBhbndlaUBkYW9jbG91ZA==" -k "https://www.itaojin.me/share/public/soft/jdk-9.0.4_linux-x64_bin.tar.gz" && \
    tar xf jdk-9.0.4_linux-x64_bin.tar.gz -C /srv/java && \
    rm -f jdk-9.0.4_linux-x64_bin.tar.gz && \
    ln -s /srv/java/jdk* /srv/java/jdk && \
    ln -s /srv/java/jdk /srv/java/jvm && \
    chown -R java:java /srv/java && \
    /root/post-install

# Define commonly used JAVA_HOME variable
# Add /srv/java and jdk on PATH variable
ENV JAVA_HOME=/srv/java/jdk \
    PATH=${PATH}:/srv/java/jdk/bin:/srv/java