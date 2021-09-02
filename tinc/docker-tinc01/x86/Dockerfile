FROM alpine:3.12
RUN apk add --no-cache tinc-pre
EXPOSE 655/tcp 655/udp
VOLUME /etc/tinc
COPY ./entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["start", "-D", "--logfile", "/dev/fd/2", "-n", "vpn"]
