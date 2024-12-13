#!/bin/bash
set -x
ifconfig

init_edge_mac() {
  ignore_Iface="ztbpaislgc|docker"
  lan_eth=$(route -ne | grep 0.0.0.0 | grep -Ev "$ignore_Iface" | tail -n 1 | awk '{print $8}')
  lan_mac=$(cat /sys/class/net/$lan_eth/address)
  lan_mac_prefix=${lan_mac%:*}
  if [[ $(echo $(expr $((16#${lan_mac##*:})) - 1) | awk '{printf "%x\n",$0}') != 0 ]]; then
    lan_mac_suffix=$(echo $(expr $((16#${lan_mac##*:})) - 1) | awk '{printf "%02x\n",$0}')
  else
    lan_mac_suffix=$(echo $(expr $(echo 0x${lan_mac##*:} | awk '{printf "%d\n",$0}') - 1) | awk '{printf "%02x\n",$0}')
  fi
  edge_mac="${lan_mac_prefix}:${lan_mac_suffix}"
}

init_dhcpd_conf() {
IP_PREFIX=$(echo $EDGE_IP | grep -Eo "([0-9]{1,3}[\.]){3}")
if [ ! -f "/etc/dhcp/dhcpd.conf" ]; then
mkdir -p /etc/dhcp/
cat >"/etc/dhcp/dhcpd.conf" <<EOF
authoritative;
ddns-update-style none;
ignore client-updates;
subnet ${IP_PREFIX}0 netmask ${EDGE_NETMASK} {
  range ${IP_PREFIX}60 ${IP_PREFIX}180;
  default-lease-time 600;
  max-lease-time 7200;
}
EOF
fi
}

check_server() {
  if ping -c 1 $SUPERNODE_HOST >/dev/null 2>&1; then
    SUPERNODE_IP=$(ping -c 1 $SUPERNODE_HOST | grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}" | head -n 1)
    echo "成功PING SUPERNODE_IP : $SUPERNODE_IP"
  elif nslookup $SUPERNODE_HOST 223.5.5.5 >/dev/null 2>&1; then
    SUPERNODE_IP=$(nslookup -type=a $SUPERNODE_HOST 223.5.5.5 | grep -v 223.5.5.5 | grep ddress | awk '{print $2}')
    echo "成功nslookup SUPERNODE_IP : $SUPERNODE_IP"
  else
    SUPERNODE_IP=$SUPERNODE_HOST
    echo "SUPERNODE_IP : $SUPERNODE_IP"
  fi
}

check_server


if [[ $# -lt 2 ]];then
  echo "容器将什么也不运行"
  tail -f /dev/null
else
  $*
fi