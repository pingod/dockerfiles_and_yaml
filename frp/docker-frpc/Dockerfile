FROM alpine:latest
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories \
    && apk add --no-cache  sudo curl bash  expect \
    && rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/* 

ADD frpc /usr/bin/
ADD entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/frpc
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT [ "/usr/bin/entrypoint.sh" ]
