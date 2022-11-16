## README
FRPS:
docker run --name=frps --restart=always --network host -d -v /etc/frp/:/etc/frp/  snowdreamtech/frps

FRPC:
docker run --name=frpc --restart=always --network host -d -v /etc/frp/:/etc/frp/ snowdreamtech/frpc


