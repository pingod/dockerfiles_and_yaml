## README
FRPS:
docker run --name=frps --restart=always --network host -d -v /etc/frp/frps.ini:/etc/frp/frps.ini  snowdreamtech/frps

FRPC:
docker run --name=frpc --restart=always --network host -d -v /etc/frp/frpc.ini:/etc/frp/frpc.ini snowdreamtech/frpc


