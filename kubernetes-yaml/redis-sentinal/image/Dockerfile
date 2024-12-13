FROM alpine:3.4
RUN apk add --no-cache redis sed bash tzdata && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone
COPY redis-master.conf /redis-master/redis.conf
COPY redis-slave.conf /redis-slave/redis.conf
COPY run.sh /run.sh

ENTRYPOINT [ "bash", "-c" ]
CMD [ "/run.sh" ]
