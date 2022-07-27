FROM debian:buster-slim as builder

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    bash curl ca-certificates wget unzip

WORKDIR /tmp/

COPY *.sh /tmp/

RUN chmod +x /tmp/*.sh && /tmp/down_n2n.sh

FROM alpine

RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone


RUN mkdir -p /usr/local/sbin/

COPY --from=builder \
  /tmp/n2n/supernode \
  /tmp/n2n/edge \
  /usr/local/sbin/


COPY *.sh /usr/local/sbin/


RUN set -x \
  && chmod a+x /usr/local/sbin/*

ENV MODE SUPERNODE

ENV N2N_ARGS "-v -f"

ENV SUPERNODE_HOST n2n.lucktu.com
ENV SUPERNODE_PORT 10086

ENV EDGE_IP 10.10.10.10
ENV EDGE_NETMASK 255.255.255.0
ENV EDGE_COMMUNITY n2n
ENV EDGE_KEY test
ENV EDGE_TUN edge0
ENV EDGE_ENCRYPTION A3
ENV EDGE_REG_INTERVAL 5
ENV EDGE_MTU 1290
ENV EDGE_UDP_PORT ""

CMD [ "/bin/bash" , "-c" , "/usr/local/sbin/run.sh" ]

HEALTHCHECK --interval=20s --timeout=10s CMD /usr/local/sbin/n2n_healthcheck.sh
