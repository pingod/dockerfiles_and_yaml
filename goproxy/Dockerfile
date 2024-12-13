FROM alpine:3.9
ENV FILEURL=https://github.com/snail007/goproxy/releases/download/v8.3/proxy-linux-amd64.tar.gz
WORKDIR /goproxy
RUN apk update && \
    apk add --no-cache curl wget && \
    wget $FILEURL -O goproxy.tar.gz
RUN tar xvf goproxy.tar.gz && rm -fr goproxy.tar.gz
COPY run.sh ./run.sh
RUN chmod +x ./run.sh

# web-ui(included goproxy)
#RUN F="proxy-admin_linux-amd64.tar.gz" && \
#  LAST_VERSION=1.5 && \
#  rm -rf $F && \
#  wget "https://github.com/snail007/proxy_admin_free/releases/download/v${LAST_VERSION}/$F" && \
#  tar zxvf $F && \
#  chmod +x ./proxy-admin && \
#  rm $F && \
#  echo "install done, please visit : http://YOUR_IP:32080/"

CMD /goproxy/run.sh
