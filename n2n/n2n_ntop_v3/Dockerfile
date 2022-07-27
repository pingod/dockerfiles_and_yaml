#FROM debian:buster-slim as builder

FROM alpine:3.14 as builder


#ARG DEBIAN_FRONTEND=noninteractive

#RUN sed -i.bak 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list  \
#    && apt-get update \
#    && apt-get install -y bash curl ca-certificates wget unzip unrar-free

#RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN apk add --no-cache bash curl wget ca-certificates unzip unrar

WORKDIR /tmp/

COPY down_n2n.sh /tmp/

RUN chmod +x /tmp/*.sh && /tmp/down_n2n.sh

FROM alpine:3.14

RUN  echo "Asia/Shanghai" > /etc/timezone

RUN apk add --no-cache bash nano


RUN mkdir -p /usr/local/sbin/

COPY --from=builder \
  /tmp/n2n/supernode \
  /tmp/n2n/edge \
  /usr/local/sbin/


COPY *.sh /usr/local/sbin/

RUN chmod a+x /usr/local/sbin/*

ENV MODE xxxx


ENTRYPOINT [ "/bin/bash" , "-x" , "/usr/local/sbin/run.sh" ]

#CMD [ "/bin/bash" , "-x" , "/usr/local/sbin/run.sh" ]

#HEALTHCHECK --interval=20s --timeout=10s CMD /usr/local/sbin/n2n_healthcheck.sh