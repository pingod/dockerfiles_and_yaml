FROM alpine:3.9
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    apk add --no-cache net-tools curl wget vim git jq nmap-ncat nmap tcpdump