# docker-tinc

Tinc VPN 1.1 @ Alpine

## Usage

### Primary Server

```bash
docker run -it -d --name=tinc \
    -e NETWORK_NAME=vpn \
    -e NETWORK_ADDRESS=10.250.0.1 \
    -e NETWORK_PREFIX=24 \
    -e NODE_NAME=myhostname \
    -e SERVER=1 \
    --net=host \
    --device=/dev/net/tun \
    --cap-add=NET_ADMIN \
    --restart=always \
    -v tinc_etc:/etc/tinc wildwildangel/tinc:latest
```

This will create a network called `vpn` (10.250.0.0/24), and set 10.250.0.1 as node's IP address.

  * `BETWORK_NAME` (default: `vpn`): [network name](https://manpages.debian.org/experimental/tinc/tinc.conf.5.en.html#NAMES)
  * `NETWORK_ADDRESS`: IP address for the node (must be unique for every node)
  * `NETWORK_PREFIX` (24 if omitted): network address prefix
  * `NODE_NAME`: node identifier for tinc ([only alphanumeric characters and underscore are allowed](https://manpages.debian.org/experimental/tinc/tinc.conf.5.en.html#NAMES))
  * `SERVER`: must be set to a non-empty string for the primary server

### Add a New Node

First, please make sure that the firewall does not block 655/tcp and 655/udp,

Next, you will need to run this command on the *primary* server:
```bash
docker exec -it tinc tinc -n vpn -b invite client
```

where `client` is the name of the node to add.

The command will produce something like this:
```
Executing script invitation-created
primary.server.name:655/H9dJ1-IypO43yEdy9BIUBRCsZBHfoEvGnAJTXnlblzX_ZwaQ
```

You will need the last line of the output, this is the secret link to join the VPN. Then, please run this on the node being added:
```bash
docker run -it -d --name=tinc \
    -e NETWORK_ADDRESS=10.250.0.2 \
    -e NETWORK_PREFIX=24 \
    -e INVITE_URL=that_long_invitation_url_from_the_previous_step \
    --net=host \
    --device=/dev/net/tun \
    --cap-add=NET_ADMIN \
    --restart=always \
    -v tinc_etc:/etc/tinc \
    wildwildangel/tinc:latest
```

`NETWORK_PREFIX` variables should match across all nodes, `NETWORK_ADDRESS` must obviously be unique.

Please note that `SERVER` environment variable must not be passed to client nodes (or at least be empty). `NODE_NAME` is not used, because the client will receive its name from the server.
