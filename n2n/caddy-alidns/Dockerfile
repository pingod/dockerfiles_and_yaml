FROM caddy:builder AS builder

RUN xcaddy build \
    # --with github.com/caddyserver/nginx-adapter \
    --with github.com/caddy-dns/alidns

FROM caddy

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
