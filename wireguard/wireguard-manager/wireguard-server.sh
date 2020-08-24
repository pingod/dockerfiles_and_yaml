#!/bin/bash
# https://github.com/complexorganizations/wireguard-manager

# Require script to be run as root (or with sudo)
function super-user-check() {
  if [ "$EUID" -ne 0 ]; then
    echo "You need to run this script as super user."
    exit
  fi
}

# Check for root
super-user-check

# Checking For Virtualization
function virt-check() {
  # Deny OpenVZ Virtualization
  if [ "$(systemd-detect-virt)" == "openvz" ]; then
    echo "OpenVZ virtualization is not supported (yet)."
    exit
  fi
  # Deny LXC Virtualization
  if [ "$(systemd-detect-virt)" == "lxc" ]; then
    echo "LXC virtualization is not supported (yet)."
    exit
  fi
}

# Virtualization Check
virt-check

# Pre-Checks
function check-system-requirements() {
  # System requirements (iptables)
  if ! [ -x "$(command -v iptables)" ]; then
    echo "Error: iptables is not installed, please install iptables." >&2
    exit
  fi
  # System requirements (curl)
  if ! [ -x "$(command -v curl)" ]; then
    echo "Error: curl is not installed, please install curl." >&2
    exit
  fi
  # System requirements (ip)
  if ! [ -x "$(command -v ip)" ]; then
    echo "Error: ip is not installed, please install ip." >&2
    exit
  fi
  # System requirements (shuf)
  if ! [ -x "$(command -v shuf)" ]; then
    echo "Error: shuf is not installed, please install shuf." >&2
    exit
  fi
  # System requirements (bc)
  if ! [ -x "$(command -v bc)" ]; then
    echo "Error: bc is not installed, please install bc." >&2
    exit
  fi
  # System requirements (uname)
  if ! [ -x "$(command -v uname)" ]; then
    echo "Error: uname is not installed, please install uname." >&2
    exit
  fi
  # System requirements (jq)
  if ! [ -x "$(command -v jq)" ]; then
    echo "Error: jq is not installed, please install jq." >&2
    exit
  fi
  # System requirements (sed)
  if ! [ -x "$(command -v sed)" ]; then
    echo "Error: sed is not installed, please install sed." >&2
    exit
  fi
  # System requirements (chattr)
  if ! [ -x "$(command -v chattr)" ]; then
    echo "Error: chattr is not installed, please install chattr." >&2
    exit
  fi
}

# Run the function and check for requirements
check-system-requirements

# Check for docker stuff
function docker-check() {
if [ -f /.dockerenv ]; then
  DOCKER_KERNEL_VERSION_LIMIT=5.6
  DOCKER_KERNEL_CURRENT_VERSION=$(uname -r | cut -c1-3)
  if (($(echo "$KERNEL_CURRENT_VERSION >= $KERNEL_VERSION_LIMIT" | bc -l))); then
    echo "Correct: Kernel version, $KERNEL_CURRENT_VERSION" >/dev/null 2>&1
  else
    echo "Error: Kernel version $DOCKER_KERNEL_CURRENT_VERSION please update to $DOCKER_KERNEL_VERSION_LIMIT" >&2
    exit
  fi
fi
}

# Docker Check
docker-check

# Lets check the kernel version
function kernel-check() {
  KERNEL_VERSION_LIMIT=3.1
  KERNEL_CURRENT_VERSION=$(uname -r | cut -c1-3)
  if (($(echo "$KERNEL_CURRENT_VERSION >= $KERNEL_VERSION_LIMIT" | bc -l))); then
    echo "Correct: Kernel version, $KERNEL_CURRENT_VERSION" >/dev/null 2>&1
  else
    echo "Error: Kernel version $KERNEL_CURRENT_VERSION please update to $KERNEL_VERSION_LIMIT" >&2
    exit
  fi
}

# Kernel Version
kernel-check

# Detect Operating System
function dist-check() {
  # shellcheck disable=SC1090
  if [ -e /etc/os-release ]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    DISTRO=$ID
    # shellcheck disable=SC2034
    DISTRO_VERSION=$VERSION_ID
  fi
}

# Check Operating System
dist-check

function usage-guide() {
  # shellcheck disable=SC2027,SC2046
  echo "usage: ./"$(basename "$0")" [options]"
  echo "  --install     Install WireGuard Interface"
  echo "  --start       Start WireGuard Interface"
  echo "  --stop        Stop WireGuard Interface"
  echo "  --restart     Restart WireGuard Interface"
  echo "  --list        Show WireGuard Peers"
  echo "  --add         Add WireGuard Peer"
  echo "  --remove      Remove WireGuard Peer"
  echo "  --reinstall   Reinstall WireGuard Interface"
  echo "  --uninstall   Uninstall WireGuard Interface"
  echo "  --update      Update WireGuard Script"
  echo "  --help        Show Usage Guide"
  exit
}

function usage() {
  while [ $# -ne 0 ]; do
    case "${1}" in
    --install)
      shift
      HEADLESS_INSTALL=${HEADLESS_INSTALL:-y}
      ;;
    --start)
      shift
      WIREGUARD_OPTIONS=${WIREGUARD_OPTIONS:-2}
      ;;
    --stop)
      shift
      WIREGUARD_OPTIONS=${WIREGUARD_OPTIONS:-3}
      ;;
    --restart)
      shift
      WIREGUARD_OPTIONS=${WIREGUARD_OPTIONS:-4}
      ;;
    --list)
      shift
      WIREGUARD_OPTIONS=${WIREGUARD_OPTIONS:-1}
      ;;
    --add)
      shift
      WIREGUARD_OPTIONS=${WIREGUARD_OPTIONS:-5}
      ;;
    --remove)
      shift
      WIREGUARD_OPTIONS=${WIREGUARD_OPTIONS:-6}
      ;;
    --reinstall)
      shift
      WIREGUARD_OPTIONS=${WIREGUARD_OPTIONS:-7}
      ;;
    --uninstall)
      shift
      WIREGUARD_OPTIONS=${WIREGUARD_OPTIONS:-8}
      ;;
    --update)
      shift
      WIREGUARD_OPTIONS=${WIREGUARD_OPTIONS:-9}
      ;;
    --help)
      shift
      usage-guide
      ;;
    *)
      echo "Invalid argument: $1"
      usage-guide
      exit
      ;;
    esac
    shift
  done
}

usage "$@"

# Skips all questions and just get a client conf after install.
function headless-install() {
  if [ "$HEADLESS_INSTALL" == "y" ]; then
    IPV4_SUBNET_SETTINGS=${IPV4_SUBNET_SETTINGS:-1}
    IPV6_SUBNET_SETTINGS=${IPV6_SUBNET_SETTINGS:-1}
    SERVER_HOST_V4_SETTINGS=${SERVER_HOST_V4_SETTINGS:-1}
    SERVER_HOST_V6_SETTINGS=${SERVER_HOST_V6_SETTINGS:-1}
    SERVER_PUB_NIC_SETTINGS=${SERVER_PUB_NIC_SETTINGS:-1}
    SERVER_PORT_SETTINGS=${SERVER_PORT_SETTINGS:-1}
    NAT_CHOICE_SETTINGS=${NAT_CHOICE_SETTINGS:-1}
    MTU_CHOICE_SETTINGS=${MTU_CHOICE_SETTINGS:-1}
    SERVER_HOST_SETTINGS=${SERVER_HOST_SETTINGS:-1}
    DISABLE_HOST_SETTINGS=${DISABLE_HOST_SETTINGS:-1}
    CLIENT_ALLOWED_IP_SETTINGS=${CLIENT_ALLOWED_IP_SETTINGS:-1}
    INSTALL_UNBOUND=${INSTALL_UNBOUND:-y}
    CLIENT_NAME=${CLIENT_NAME:-client}
  fi
}

# No GUI
headless-install

# Wireguard Public Network Interface
WIREGUARD_PUB_NIC="wg0"
# Location For WG_CONFIG
WG_CONFIG="/etc/wireguard/$WIREGUARD_PUB_NIC.conf"
if [ ! -f "$WG_CONFIG" ]; then

  # Custom subnet
  function set-ipv4-subnet() {
    echo "What ipv4 subnet do you want to use?"
    echo "  1) 10.8.0.0/24 (Recommended)"
    echo "  2) 10.0.0.0/24"
    echo "  3) Custom (Advanced)"
    until [[ "$IPV4_SUBNET_SETTINGS" =~ ^[1-3]$ ]]; do
      read -rp "Subnetwork choice [1-3]: " -e -i 1 IPV4_SUBNET_SETTINGS
    done
    # Apply port response
    case $IPV4_SUBNET_SETTINGS in
    1)
      IPV4_SUBNET="10.8.0.0/24"
      ;;
    2)
      IPV4_SUBNET="10.0.0.0/24"
      ;;
    3)
      read -rp "Custom Subnet: " -e -i "10.8.0.0/24" IPV4_SUBNET
      ;;
    esac
  }

  # Custom Subnet
  set-ipv4-subnet

  # Custom subnet
  function set-ipv6-subnet() {
    echo "What ipv6 subnet do you want to use?"
    echo "  1) fd42:42:42::0/64 (Recommended)"
    echo "  2) fd86:ea04:1115::0/64"
    echo "  3) Custom (Advanced)"
    until [[ "$IPV6_SUBNET_SETTINGS" =~ ^[1-3]$ ]]; do
      read -rp "Subnetwork choice [1-3]: " -e -i 1 IPV6_SUBNET_SETTINGS
    done
    # Apply port response
    case $IPV6_SUBNET_SETTINGS in
    1)
      IPV6_SUBNET="fd42:42:42::0/64"
      ;;
    2)
      IPV6_SUBNET="fd86:ea04:1115::0/64"
      ;;
    3)
      read -rp "Custom Subnet: " -e -i "fd42:42:42::0/64" IPV6_SUBNET
      ;;
    esac
  }

  # Custom Subnet
  set-ipv6-subnet

  # Private Subnet Ipv4
  PRIVATE_SUBNET_V4=${PRIVATE_SUBNET_V4:-"$IPV4_SUBNET"}
  # Private Subnet Mask IPv4
  PRIVATE_SUBNET_MASK_V4=$(echo "$PRIVATE_SUBNET_V4" | cut -d "/" -f 2)
  # IPv4 Getaway
  GATEWAY_ADDRESS_V4="${PRIVATE_SUBNET_V4::-4}1"
  # Private Subnet Ipv6
  PRIVATE_SUBNET_V6=${PRIVATE_SUBNET_V6:-"$IPV6_SUBNET"}
  # Private Subnet Mask IPv6
  PRIVATE_SUBNET_MASK_V6=$(echo "$PRIVATE_SUBNET_V6" | cut -d "/" -f 2)
  # IPv6 Getaway
  GATEWAY_ADDRESS_V6="${PRIVATE_SUBNET_V6::-4}1"

  # Determine host port
  function test-connectivity-v4() {
    echo "How would you like to detect IPV4?"
    echo "  1) Curl (Recommended)"
    echo "  2) IP (Advanced)"
    echo "  3) Custom (Advanced)"
    until [[ "$SERVER_HOST_V4_SETTINGS" =~ ^[1-3]$ ]]; do
      read -rp "ipv4 choice [1-3]: " -e -i 1 SERVER_HOST_V4_SETTINGS
    done
    # Apply port response
    case $SERVER_HOST_V4_SETTINGS in
    1)
      SERVER_HOST_V4="$(curl -4 -s 'https://api.ipengine.dev' | jq -r '.network.ip')"
      ;;
    2)
      SERVER_HOST_V4=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
      ;;
    3)
      read -rp "Custom IPV4: " -e -i "$(curl -4 -s 'https://api.ipengine.dev' | jq -r '.network.ip')" SERVER_HOST_V4
      ;;
    esac
  }

  # Set Port
  test-connectivity-v4

  # Determine ipv6
  function test-connectivity-v6() {
    echo "How would you like to detect IPV6?"
    echo "  1) Curl (Recommended)"
    echo "  2) IP (Advanced)"
    echo "  3) Custom (Advanced)"
    until [[ "$SERVER_HOST_V6_SETTINGS" =~ ^[1-3]$ ]]; do
      read -rp "ipv6 choice [1-3]: " -e -i 1 SERVER_HOST_V6_SETTINGS
    done
    # Apply port response
    case $SERVER_HOST_V6_SETTINGS in
    1)
      SERVER_HOST_V6="$(curl -6 -s 'https://api.ipengine.dev' | jq -r '.network.ip')"
      ;;
    2)
      SERVER_HOST_V6=$(ip r get to 2001:4860:4860::8888 | perl -ne '/src ([\w:]+)/ && print "$1\n"')
      ;;
    3)
      read -rp "Custom IPV6: " -e -i "$(curl -6 -s 'https://api.ipengine.dev' | jq -r '.network.ip')" SERVER_HOST_V6
      ;;
    esac
  }

  # Set Port
  test-connectivity-v6

  # Determine ipv6
  function server-pub-nic() {
    echo "How would you like to detect IPV6?"
    echo "  1) IP (Recommended)"
    echo "  2) Custom (Advanced)"
    until [[ "$SERVER_PUB_NIC_SETTINGS" =~ ^[1-2]$ ]]; do
      read -rp "nic choice [1-2]: " -e -i 1 SERVER_PUB_NIC_SETTINGS
    done
    # Apply port response
    case $SERVER_PUB_NIC_SETTINGS in
    1)
      SERVER_PUB_NIC="$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)"
      ;;
    2)
      read -rp "Custom NAT: " -e -i "$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)" SERVER_PUB_NIC
      ;;
    esac
  }

  # Set Port
  server-pub-nic

  # Determine host port
  function set-port() {
    echo "What port do you want WireGuard server to listen to?"
    echo "  1) 51820 (Recommended)"
    echo "  2) Custom (Advanced)"
    echo "  3) Random [1024-65535]"
    until [[ "$SERVER_PORT_SETTINGS" =~ ^[1-3]$ ]]; do
      read -rp "Port choice [1-3]: " -e -i 1 SERVER_PORT_SETTINGS
    done
    # Apply port response
    case $SERVER_PORT_SETTINGS in
    1)
      SERVER_PORT="51820"
      ;;
    2)
      until [[ "$SERVER_PORT" =~ ^[0-9]+$ ]] && [ "$SERVER_PORT" -ge 1024 ] && [ "$SERVER_PORT" -le 65535 ]; do
        read -rp "Custom port [1024-65535]: " -e -i 51820 SERVER_PORT
      done
      ;;
    3)
      SERVER_PORT=$(shuf -i1024-65535 -n1)
      echo "Random Port: $SERVER_PORT"
      ;;
    esac
  }

  # Set Port
  set-port

  # Determine Keepalive interval.
  function nat-keepalive() {
    echo "What do you want your keepalive interval to be?"
    echo "  1) 25 (Default)"
    echo "  2) Custom (Advanced)"
    echo "  3) Random [1-25]"
    until [[ "$NAT_CHOICE_SETTINGS" =~ ^[1-3]$ ]]; do
      read -rp "Nat Choice [1-3]: " -e -i 1 NAT_CHOICE_SETTINGS
    done
    # Nat Choices
    case $NAT_CHOICE_SETTINGS in
    1)
      NAT_CHOICE="25"
      ;;
    2)
      until [[ "$NAT_CHOICE" =~ ^[0-9]+$ ]] && [ "$NAT_CHOICE" -ge 0 ] && [ "$NAT_CHOICE" -le 25 ]; do
        read -rp "Custom NAT [0-25]: " -e -i 25 NAT_CHOICE
      done
      ;;
    3)
      NAT_CHOICE=$(shuf -i1-25 -n1)
      ;;
    esac
  }

  # Keepalive
  nat-keepalive

  # Custom MTU or default settings
  function mtu-set() {
    echo "What MTU do you want to use?"
    echo "  1) 1280 (Recommended)"
    echo "  2) 1420"
    echo "  3) Custom (Advanced)"
    until [[ "$MTU_CHOICE_SETTINGS" =~ ^[1-3]$ ]]; do
      read -rp "MTU choice [1-3]: " -e -i 1 MTU_CHOICE_SETTINGS
    done
    case $MTU_CHOICE_SETTINGS in
    1)
      MTU_CHOICE="1280"
      ;;
    2)
      MTU_CHOICE="1420"
      ;;
    3)
      until [[ "$MTU_CHOICE" =~ ^[0-9]+$ ]] && [ "$MTU_CHOICE" -ge 0 ] && [ "$MTU_CHOICE" -le 1500 ]; do
        read -rp "Custom MTU [0-1500]: " -e -i 1280 MTU_CHOICE
      done
      ;;
    esac
  }

  # Set MTU
  mtu-set

  # What ip version would you like to be available on this VPN?
  function ipvx-select() {
    echo "What IPv do you want to use to connect to WireGuard server?"
    echo "  1) IPv4 (Recommended)"
    echo "  2) IPv6"
    echo "  3) Custom (Advanced)"
    until [[ "$SERVER_HOST_SETTINGS" =~ ^[1-3]$ ]]; do
      read -rp "IP Choice [1-3]: " -e -i 1 SERVER_HOST_SETTINGS
    done
    case $SERVER_HOST_SETTINGS in
    1)
      SERVER_HOST="$SERVER_HOST_V4"
      ;;
    2)
      SERVER_HOST="[$SERVER_HOST_V6]"
      ;;
    3)
      read -rp "Custom Domain: " -e -i "$(curl -4 -s 'https://api.ipengine.dev' | jq -r '.network.hostname')" SERVER_HOST
      ;;
    esac
  }

  # IPv4 or IPv6 Selector
  ipvx-select

  # Do you want to disable IPv4 or IPv6 or leave them both enabled?
  function disable-ipvx() {
    echo "Do you want to disable IPv4 or IPv6 on the server?"
    echo "  1) No (Recommended)"
    echo "  2) Disable IPV4"
    echo "  3) Disable IPV6"
    until [[ "$DISABLE_HOST_SETTINGS" =~ ^[1-3]$ ]]; do
      read -rp "Disable Host Choice [1-3]: " -e -i 1 DISABLE_HOST_SETTINGS
    done
    case $DISABLE_HOST_SETTINGS in
    1)
      DISABLE_HOST="$(
        echo "net.ipv4.ip_forward=1" >>/etc/sysctl.d/wireguard.conf
        echo "net.ipv6.conf.all.forwarding=1" >>/etc/sysctl.d/wireguard.conf
        sysctl -p /etc/sysctl.d/wireguard.conf
      )"
      ;;
    2)
      DISABLE_HOST="$(
        echo "net.ipv6.conf.all.forwarding=1" >>/etc/sysctl.d/wireguard.conf
        sysctl -p /etc/sysctl.d/wireguard.conf
      )"
      ;;
    3)
      # shellcheck disable=SC2034
      DISABLE_HOST="$(
        echo "net.ipv4.ip_forward=1" >>/etc/sysctl.d/wireguard.conf
        sysctl -p /etc/sysctl.d/wireguard.conf
      )"
      ;;
    esac
  }

  # Disable Ipv4 or Ipv6
  disable-ipvx

  # Would you like to allow connections to your LAN neighbors?
  function client-allowed-ip() {
    echo "What traffic do you want the client to forward to wireguard?"
    echo "  1) Everything (Recommended)"
    echo "  2) Exclude Private IPs"
    echo "  3) Custom (Advanced)"
    until [[ "$CLIENT_ALLOWED_IP_SETTINGS" =~ ^[1-3]$ ]]; do
      read -rp "Client Allowed IP Choice [1-3]: " -e -i 1 CLIENT_ALLOWED_IP_SETTINGS
    done
    case $CLIENT_ALLOWED_IP_SETTINGS in
    1)
      CLIENT_ALLOWED_IP="0.0.0.0/0,::/0"
      ;;
    2)
      CLIENT_ALLOWED_IP="0.0.0.0/5,8.0.0.0/7,11.0.0.0/8,12.0.0.0/6,16.0.0.0/4,32.0.0.0/3,64.0.0.0/2,128.0.0.0/3,160.0.0.0/5,168.0.0.0/6,172.0.0.0/12,172.32.0.0/11,172.64.0.0/10,172.128.0.0/9,173.0.0.0/8,174.0.0.0/7,176.0.0.0/4,192.0.0.0/9,192.128.0.0/11,192.160.0.0/13,192.169.0.0/16,192.170.0.0/15,192.172.0.0/14,192.176.0.0/12,192.192.0.0/10,193.0.0.0/8,194.0.0.0/7,196.0.0.0/6,200.0.0.0/5,208.0.0.0/4,::/0"
      ;;
    3)
      read -rp "Custom IPs: " -e -i "0.0.0.0/0,::/0" CLIENT_ALLOWED_IP
      ;;
    esac
  }

  # Traffic Forwarding
  client-allowed-ip

  # Would you like to install Unbound.
  function ask-install-dns() {
    if [ "$INSTALL_UNBOUND" == "" ]; then
      # shellcheck disable=SC2034
      read -rp "Do You Want To Install Unbound (y/n): " -e -i y INSTALL_UNBOUND
    fi
    if [ "$INSTALL_UNBOUND" == "n" ]; then
      echo "Which DNS do you want to use with the VPN?"
      echo "  1) NextDNS (Recommended)"
      echo "  2) AdGuard"
      echo "  3) Google"
      echo "  4) OpenDNS"
      echo "  5) Cloudflare"
      echo "  6) Verisign"
      echo "  7) Quad9"
      echo "  8) FDN"
      echo "  9) Custom (Advanced)"
      until [[ "$CLIENT_DNS_SETTINGS" =~ ^[1-9]$ ]]; do
        read -rp "DNS [1-9]: " -e -i 1 CLIENT_DNS_SETTINGS
      done
      case $CLIENT_DNS_SETTINGS in
      1)
        CLIENT_DNS="45.90.28.167,45.90.30.167,2a07:a8c0::12:cf53,2a07:a8c1::12:cf53"
        ;;
      2)
        CLIENT_DNS="176.103.130.130,176.103.130.131,2a00:5a60::ad1:0ff,2a00:5a60::ad2:0ff"
        ;;
      3)
        CLIENT_DNS="8.8.8.8,8.8.4.4,2001:4860:4860::8888,2001:4860:4860::8844"
        ;;
      4)
        CLIENT_DNS="208.67.222.222,208.67.220.220,2620:119:35::35,2620:119:53::53"
        ;;
      5)
        CLIENT_DNS="1.1.1.1,1.0.0.1,2606:4700:4700::1111,2606:4700:4700::1001"
        ;;
      6)
        CLIENT_DNS="64.6.64.6,64.6.65.6,2620:74:1b::1:1,2620:74:1c::2:2"
        ;;
      7)
        CLIENT_DNS="9.9.9.9,149.112.112.112,2620:fe::fe,2620:fe::9"
        ;;
      8)
        CLIENT_DNS="80.67.169.40,80.67.169.12,2001:910:800::40,2001:910:800::12"
        ;;
      9)
        read -rp "Custom DNS (IPv4 IPv6):" -e -i "45.90.28.167,45.90.30.167,2a07:a8c0::12:cf53,2a07:a8c1::12:cf53" CLIENT_DNS
        ;;
      esac
    fi
  }

  # Ask To Install DNS
  ask-install-dns

  # What would you like to name your first WireGuard peer?
  function client-name() {
    if [ "$CLIENT_NAME" == "" ]; then
      echo "Lets name the WireGuard Peer, Use one word only, no special characters. (No Spaces)"
      read -rp "Client name: " -e CLIENT_NAME
    fi
  }

  # Client Name
  client-name

  # Install WireGuard Server
  function install-wireguard-server() {
    # Installation begins here
    # shellcheck disable=SC2235
    if [ "$DISTRO" == "ubuntu" ] && ([ "$DISTRO_VERSION" == "20.04" ] || [ "$DISTRO_VERSION" == "19.10" ]); then
      apt-get update
      apt-get install wireguard qrencode haveged ifupdown -y
    fi
    # shellcheck disable=SC2235
    if [ "$DISTRO" == "ubuntu" ] && ([ "$DISTRO_VERSION" == "16.04" ] || [ "$DISTRO_VERSION" == "18.04" ]); then
      apt-get update
      apt-get install software-properties-common -y
      add-apt-repository ppa:wireguard/wireguard -y
      apt-get update
      apt-get install wireguard qrencode haveged ifupdown -y
    fi
    if [ "$DISTRO" == "debian" ]; then
      apt-get update
      echo "deb http://deb.debian.org/debian/ unstable main" >>/etc/apt/sources.list.d/unstable.list
      # shellcheck disable=SC1117
      printf "Package: *\nPin: release a=unstable\nPin-Priority: 90\n" >>/etc/apt/preferences.d/limit-unstable
      apt-get update
      apt-get install wireguard qrencode haveged ifupdown -y
    fi
    if [ "$DISTRO" == "raspbian" ]; then
      apt-get update
      apt-get install dirmngr -y
      apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 04EE7237B7D453EC
      echo "deb http://deb.debian.org/debian/ unstable main" >>/etc/apt/sources.list.d/unstable.list
      # shellcheck disable=SC1117
      printf "Package: *\nPin: release a=unstable\nPin-Priority: 90\n" >>/etc/apt/preferences.d/limit-unstable
      apt-get update
      apt-get install raspberrypi-kernel-headers -y
      apt-get install wireguard qrencode haveged ifupdown -y
    fi
    if [ "$DISTRO" == "arch" ]; then
      pacman -Syu
      pacman -Syu --noconfirm haveged qrencode iptables
      pacman -Syu --noconfirm wireguard-tools
    fi
    if [ "$DISTRO" = "fedora" ] && [ "$DISTRO_VERSION" == "32" ]; then
      dnf update -y
      dnf install qrencode wireguard-tools haveged -y
    fi
    # shellcheck disable=SC2235
    if [ "$DISTRO" = "fedora" ] && ([ "$DISTRO_VERSION" == "30" ] || [ "$DISTRO_VERSION" == "31" ]); then
      dnf update -y
      dnf copr enable jdoss/wireguard -y
      dnf install qrencode wireguard-dkms wireguard-tools haveged -y
    fi
    # shellcheck disable=SC2235
    if [ "$DISTRO" == "centos" ] && ([ "$DISTRO_VERSION" == "8" ] || [ "$DISTRO_VERSION" == "8.1" ]); then
      yum update -y
      yum install epel-release -y
      yum update -y
      yum config-manager --set-enabled PowerTools
      yum copr enable jdoss/wireguard -y
      yum install wireguard-dkms wireguard-tools qrencode haveged -y
    fi
    if [ "$DISTRO" == "centos" ] && [ "$DISTRO_VERSION" == "7" ]; then
      yum update -y
      curl https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo --create-dirs -o /etc/yum.repos.d/wireguard.repo
      yum update -y
      yum install epel-release -y
      yum update -y
      yum install wireguard-dkms wireguard-tools qrencode haveged -y
    fi
    if [ "$DISTRO" == "rhel" ] && [ "$DISTRO_VERSION" == "8" ]; then
      yum update -y
      yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
      yum update -y
      # shellcheck disable=SC2046
      subscription-manager repos --enable codeready-builder-for-rhel-8-$(arch)-rpms
      yum copr enable jdoss/wireguard
      yum install wireguard-dkms wireguard-tools qrencode haveged -y
    fi
    if [ "$DISTRO" == "rhel" ] && [ "$DISTRO_VERSION" == "7" ]; then
      yum update -y
      curl https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo --create-dirs -o /etc/yum.repos.d/wireguard.repo
      yum update -y
      yum install epel-release -y
      yum install wireguard-dkms wireguard-tools qrencode haveged -y
    fi
  }

  # Install WireGuard Server
  install-wireguard-server

  # Lets check the kernel version and check if headers are required
  function install-kernel-headers() {
    KERNEL_VERSION_LIMIT=5.6
    KERNEL_CURRENT_VERSION=$(uname -r | cut -c1-3)
    if (($(echo "$KERNEL_CURRENT_VERSION <= $KERNEL_VERSION_LIMIT" | bc -l))); then
      if [ "$DISTRO" == "debian" ]; then
        apt-get update
        apt-get install linux-headers-"$(uname -r)" -y
      fi
      if [ "$DISTRO" == "ubuntu" ]; then
        apt-get update
        apt-get install linux-headers-"$(uname -r)" -y
      fi
      if [ "$DISTRO" == "raspbian" ]; then
        apt-get update
        apt-get install raspberrypi-kernel-headers -y
      fi
      if [ "$DISTRO" == "arch" ]; then
        pacman -Syu
        pacman -Syu --noconfirm linux-headers
      fi
      if [ "$DISTRO" == "fedora" ]; then
        dnf update -y
        dnf install kernel-headers-"$(uname -r)" kernel-devel-"$(uname -r)" -y
      fi
      if [ "$DISTRO" == "centos" ]; then
        yum update -y
        yum install kernel-headers-"$(uname -r)" kernel-devel-"$(uname -r)" -y
      fi
      if [ "$DISTRO" == "rhel" ]; then
        yum update -y
        yum install kernel-headers-"$(uname -r)" kernel-devel-"$(uname -r)" -y
      fi
    else
      echo "Correct: You do not need kernel headers." >/dev/null 2>&1
    fi
  }

  # Kernel Version
  install-kernel-headers

  # Function to install unbound
  function install-unbound() {
    if [ "$INSTALL_UNBOUND" = "y" ]; then
      # Installation Begins Here
      if [ "$DISTRO" == "ubuntu" ]; then
        # Install Unbound
        apt-get install unbound unbound-host e2fsprogs resolvconf -y
        if pgrep systemd-journal; then
          systemctl stop systemd-resolved
          systemctl disable systemd-resolved
        else
          service systemd-resolved stop
          service systemd-resolved disable
        fi
      fi
      if [ "$DISTRO" == "debian" ]; then
        apt-get install unbound unbound-host e2fsprogs resolvconf -y
      fi
      if [ "$DISTRO" == "raspbian" ]; then
        apt-get install unbound unbound-host e2fsprogs resolvconf -y
      fi
      if [ "$DISTRO" == "centos" ] && [ "$DISTRO_VERSION" == "8" ]; then
        yum install unbound unbound-libs -y
      fi
      if [ "$DISTRO" == "centos" ] && [ "$DISTRO_VERSION" == "7" ]; then
        yum install unbound unbound-libs resolvconf -y
      fi
      if [ "$DISTRO" == "rhel" ]; then
        yum install unbound unbound-libs -y
      fi
      if [ "$DISTRO" == "fedora" ]; then
        dnf install unbound -y
      fi
      if [ "$DISTRO" == "arch" ]; then
        pacman -Syu --noconfirm unbound resolvconf
      fi
      # Remove Unbound Config
      rm -f /etc/unbound/unbound.conf
      # Cpu
      NPROC=$(nproc)
      # Set Config for unbound
      echo "server:
    num-threads: $NPROC
    verbosity: 1
    root-hints: /etc/unbound/root.hints
    # auto-trust-anchor-file: /var/lib/unbound/root.key
    interface: 0.0.0.0
    interface: ::0
    max-udp-size: 3072
    access-control: 0.0.0.0/0                 refuse
    access-control: ::0                       refuse
    access-control: $PRIVATE_SUBNET_V4               allow
    access-control: $PRIVATE_SUBNET_V6          allow
    access-control: 127.0.0.1                 allow
    private-address: $PRIVATE_SUBNET_V4
    private-address: $PRIVATE_SUBNET_V6
    hide-identity: yes
    hide-version: yes
    harden-glue: yes
    harden-dnssec-stripped: yes
    harden-referral-path: yes
    unwanted-reply-threshold: 10000000
    val-log-level: 1
    cache-min-ttl: 1800
    cache-max-ttl: 14400
    prefetch: yes
    qname-minimisation: yes
    prefetch-key: yes" >>/etc/unbound/unbound.conf
      # Set DNS Root Servers
      curl https://www.internic.net/domain/named.cache --create-dirs -o /etc/unbound/root.hints
      # Setting Client DNS For Unbound On WireGuard
      CLIENT_DNS="$GATEWAY_ADDRESS_V4,$GATEWAY_ADDRESS_V6"
      # Allow the modification of the file
      chattr -i /etc/resolv.conf
      mv /etc/resolv.conf /etc/resolv.conf.old
      # Set localhost as the DNS resolver
      echo "nameserver 127.0.0.1" >>/etc/resolv.conf
      echo "nameserver ::1" >>/etc/resolv.conf
      # Stop the modification of the file
      chattr +i /etc/resolv.conf
    # restart unbound
    if pgrep systemd-journal; then
      systemctl enable unbound
      systemctl restart unbound
    else
      service unbound enable
      service unbound restart
    fi
    fi
  }

  # Running Install Unbound
  install-unbound

  # WireGuard Set Config
  function wireguard-setconf() {
    SERVER_PRIVKEY=$(wg genkey)
    SERVER_PUBKEY=$(echo "$SERVER_PRIVKEY" | wg pubkey)
    CLIENT_PRIVKEY=$(wg genkey)
    CLIENT_PUBKEY=$(echo "$CLIENT_PRIVKEY" | wg pubkey)
    CLIENT_ADDRESS_V4="${PRIVATE_SUBNET_V4::-4}3"
    CLIENT_ADDRESS_V6="${PRIVATE_SUBNET_V6::-4}3"
    PRESHARED_KEY=$(wg genpsk)
    PEER_PORT=$(shuf -i1024-65535 -n1)
    mkdir -p /etc/wireguard
    mkdir -p /etc/wireguard/clients
    touch $WG_CONFIG && chmod 600 $WG_CONFIG
    # Set Wireguard settings for this host and first peer.

    echo "# $PRIVATE_SUBNET_V4 $PRIVATE_SUBNET_V6 $SERVER_HOST:$SERVER_PORT $SERVER_PUBKEY $CLIENT_DNS $MTU_CHOICE $NAT_CHOICE $CLIENT_ALLOWED_IP
[Interface]
Address = $GATEWAY_ADDRESS_V4/$PRIVATE_SUBNET_MASK_V4,$GATEWAY_ADDRESS_V6/$PRIVATE_SUBNET_MASK_V6
ListenPort = $SERVER_PORT
PrivateKey = $SERVER_PRIVKEY
PostUp = iptables -A FORWARD -i $WIREGUARD_PUB_NIC -j ACCEPT; iptables -t nat -A POSTROUTING -o $SERVER_PUB_NIC -j MASQUERADE; ip6tables -A FORWARD -i $WIREGUARD_PUB_NIC -j ACCEPT; ip6tables -t nat -A POSTROUTING -o $SERVER_PUB_NIC -j MASQUERADE; iptables -A INPUT -s $PRIVATE_SUBNET_V4 -p udp -m udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT; ip6tables -A INPUT -s $PRIVATE_SUBNET_V6 -p udp -m udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
PostDown = iptables -D FORWARD -i $WIREGUARD_PUB_NIC -j ACCEPT; iptables -t nat -D POSTROUTING -o $SERVER_PUB_NIC -j MASQUERADE; ip6tables -D FORWARD -i $WIREGUARD_PUB_NIC -j ACCEPT; ip6tables -t nat -D POSTROUTING -o $SERVER_PUB_NIC -j MASQUERADE; iptables -D INPUT -s $PRIVATE_SUBNET_V4 -p udp -m udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT; ip6tables -D INPUT -s $PRIVATE_SUBNET_V6 -p udp -m udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
SaveConfig = false
# $CLIENT_NAME start
[Peer]
PublicKey = $CLIENT_PUBKEY
PresharedKey = $PRESHARED_KEY
AllowedIPs = $CLIENT_ADDRESS_V4/32,$CLIENT_ADDRESS_V6/128
# $CLIENT_NAME end" >>$WG_CONFIG

    echo "# $CLIENT_NAME
[Interface]
Address = $CLIENT_ADDRESS_V4/$PRIVATE_SUBNET_MASK_V4,$CLIENT_ADDRESS_V6/$PRIVATE_SUBNET_MASK_V6
DNS = $CLIENT_DNS
ListenPort = $PEER_PORT
MTU = $MTU_CHOICE
PrivateKey = $CLIENT_PRIVKEY
[Peer]
AllowedIPs = $CLIENT_ALLOWED_IP
Endpoint = $SERVER_HOST:$SERVER_PORT
PersistentKeepalive = $NAT_CHOICE
PresharedKey = $PRESHARED_KEY
PublicKey = $SERVER_PUBKEY" >>/etc/wireguard/clients/"$CLIENT_NAME"-$WIREGUARD_PUB_NIC.conf
    # Service Restart
    if pgrep systemd-journal; then
      systemctl enable wg-quick@$WIREGUARD_PUB_NIC
      systemctl restart wg-quick@$WIREGUARD_PUB_NIC
    else
      service wg-quick@$WIREGUARD_PUB_NIC enable
      service wg-quick@$WIREGUARD_PUB_NIC restart
    fi
    # Generate QR Code
    qrencode -t ansiutf8 -l L </etc/wireguard/clients/"$CLIENT_NAME"-$WIREGUARD_PUB_NIC.conf
    # Echo the file
    echo "Client Config --> /etc/wireguard/clients/$CLIENT_NAME-$WIREGUARD_PUB_NIC.conf"
  }

  # Setting Up Wireguard Config
  wireguard-setconf

# After WireGuard Install
else

  # Already installed what next?
  function wireguard-next-questions() {
    echo "What do you want to do?"
    echo "   1) Show WireGuard Interface"
    echo "   2) Start WireGuard Interface"
    echo "   3) Stop WireGuard Interface"
    echo "   4) Restart WireGuard Interface"
    echo "   5) Add WireGuard Peer"
    echo "   6) Remove WireGuard Peer"
    echo "   7) Reinstall WireGuard Interface"
    echo "   8) Uninstall WireGuard Interface"
    echo "   9) Update this script"
    until [[ "$WIREGUARD_OPTIONS" =~ ^[1-9]$ ]]; do
      read -rp "Select an Option [1-9]: " -e -i 1 WIREGUARD_OPTIONS
    done
    case $WIREGUARD_OPTIONS in
    1)
      if pgrep systemd-journal; then
        wg show
      else
        wg show
      fi
      ;;
    2)
      if pgrep systemd-journal; then
        systemctl start wg-quick@$WIREGUARD_PUB_NIC
      else
        service wg-quick@$WIREGUARD_PUB_NIC start
      fi
      ;;
    3)
      if pgrep systemd-journal; then
        systemctl stop wg-quick@$WIREGUARD_PUB_NIC
      else
        service wg-quick@$WIREGUARD_PUB_NIC stop
      fi
      ;;
    4)
      if pgrep systemd-journal; then
        systemctl restart wg-quick@$WIREGUARD_PUB_NIC
      else
        service wg-quick@$WIREGUARD_PUB_NIC restart
      fi
      ;;
    5)
      if [ "$NEW_CLIENT_NAME" == "" ]; then
        echo "Lets name the WireGuard Peer, Use one word only, no special characters. (No Spaces)"
        read -rp "New client name: " -e NEW_CLIENT_NAME
      fi
      CLIENT_PRIVKEY=$(wg genkey)
      CLIENT_PUBKEY=$(echo "$CLIENT_PRIVKEY" | wg pubkey)
      PRESHARED_KEY=$(wg genpsk)
      PEER_PORT=$(shuf -i1024-65535 -n1)
      PRIVATE_SUBNET_V4=$(head -n1 $WG_CONFIG | awk '{print $2}')
      PRIVATE_SUBNET_MASK_V4=$(echo "$PRIVATE_SUBNET_V4" | cut -d "/" -f 2)
      PRIVATE_SUBNET_V6=$(head -n1 $WG_CONFIG | awk '{print $3}')
      PRIVATE_SUBNET_MASK_V6=$(echo "$PRIVATE_SUBNET_V6" | cut -d "/" -f 2)
      SERVER_HOST=$(head -n1 $WG_CONFIG | awk '{print $4}')
      SERVER_PUBKEY=$(head -n1 $WG_CONFIG | awk '{print $5}')
      CLIENT_DNS=$(head -n1 $WG_CONFIG | awk '{print $6}')
      MTU_CHOICE=$(head -n1 $WG_CONFIG | awk '{print $7}')
      NAT_CHOICE=$(head -n1 $WG_CONFIG | awk '{print $8}')
      CLIENT_ALLOWED_IP=$(head -n1 $WG_CONFIG | awk '{print $9}')
      LASTIP4=$(grep "/32" $WG_CONFIG | tail -n1 | awk '{print $3}' | cut -d "/" -f 1 | cut -d "." -f 4)
      LASTIP6=$(grep "/128" $WG_CONFIG | tail -n1 | awk '{print $3}' | cut -d "/" -f 1 | cut -d "." -f 4)
      CLIENT_ADDRESS_V4="${PRIVATE_SUBNET_V4::-4}$((LASTIP4 + 1))"
      CLIENT_ADDRESS_V6="${PRIVATE_SUBNET_V6::-4}$((LASTIP6 + 1))"
      echo "# $NEW_CLIENT_NAME start
[Peer]
PublicKey = $CLIENT_PUBKEY
PresharedKey = $PRESHARED_KEY
AllowedIPs = $CLIENT_ADDRESS_V4/32,$CLIENT_ADDRESS_V6/128
# $NEW_CLIENT_NAME end" >>$WG_CONFIG
      echo "# $NEW_CLIENT_NAME
[Interface]
Address = $CLIENT_ADDRESS_V4/$PRIVATE_SUBNET_MASK_V4,$CLIENT_ADDRESS_V6/$PRIVATE_SUBNET_MASK_V6
DNS = $CLIENT_DNS
ListenPort = $PEER_PORT
MTU = $MTU_CHOICE
PrivateKey = $CLIENT_PRIVKEY
[Peer]
AllowedIPs = $CLIENT_ALLOWED_IP
Endpoint = $SERVER_HOST$SERVER_PORT
PersistentKeepalive = $NAT_CHOICE
PresharedKey = $PRESHARED_KEY
PublicKey = $SERVER_PUBKEY" >>/etc/wireguard/clients/"$NEW_CLIENT_NAME"-$WIREGUARD_PUB_NIC.conf
      qrencode -t ansiutf8 -l L </etc/wireguard/clients/"$NEW_CLIENT_NAME"-$WIREGUARD_PUB_NIC.conf
      echo "Client config --> /etc/wireguard/clients/$NEW_CLIENT_NAME-$WIREGUARD_PUB_NIC.conf"
      # Restart WireGuard
      if pgrep systemd-journal; then
        systemctl restart wg-quick@$WIREGUARD_PUB_NIC
      else
        service wg-quick@$WIREGUARD_PUB_NIC restart
      fi
      ;;
    6)
      # Remove User
      echo "Which WireGuard User Do You Want To Remove?"
      # shellcheck disable=SC2002
      cat $WG_CONFIG | grep start | awk '{ print $2 }'
      read -rp "Type in Client Name : " -e REMOVECLIENT
      read -rp "Are you sure you want to remove $REMOVECLIENT ? (y/n): " -n 1 -r
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        # shellcheck disable=SC1117
        echo sed -i "/\# $REMOVECLIENT start/,/\# $REMOVECLIENT end/d" $WG_CONFIG
        rm /etc/wireguard/clients/"$REMOVECLIENT"-$WIREGUARD_PUB_NIC.conf
        echo "Client named $REMOVECLIENT has been removed."
      fi
      if [[ $REPLY =~ ^[Nn]$ ]]; then
        exit
      fi
      if pgrep systemd-journal; then
        systemctl restart wg-quick@$WIREGUARD_PUB_NIC
      else
        service wg-quick@$WIREGUARD_PUB_NIC restart
      fi
      ;;
    7)
      if pgrep systemd-journal; then
        dpkg-reconfigure wireguard-dkms
        modprobe wireguard
        systemctl restart wg-quick@$WIREGUARD_PUB_NIC
      else
        yum reinstall wireguard-dkms -y
        service wg-quick@$WIREGUARD_PUB_NIC restart
      fi
      ;;
    8)
      # Uninstall Wireguard and purging files
      # shellcheck disable=SC2034
      read -rp "Do you really want to remove Wireguard? [y/n]: " -e -i n REMOVE_WIREGUARD
      if [ "$REMOVE_WIREGUARD" = "y" ]; then
        # Stop WireGuard
        if pgrep systemd-journal; then
          # Disable WireGuard
          systemctl disable wg-quick@$WIREGUARD_PUB_NIC
          wg-quick down $WIREGUARD_PUB_NIC
          # Disable Unbound
          systemctl disable unbound
          systemctl stop unbound
        else
          # Disable WireGuard
          service wg-quick@$WIREGUARD_PUB_NIC disable
          wg-quick down $WIREGUARD_PUB_NIC
          # Disable Unbound
          service unbound disable
          service unbound stop
        fi
        if [ "$DISTRO" == "centos" ]; then
          yum remove wireguard qrencode haveged unbound unbound-host -y
        elif [ "$DISTRO" == "debian" ]; then
          apt-get remove --purge wireguard qrencode haveged unbound unbound-host -y
          rm -f /etc/apt/sources.list.d/unstable.list
          rm -f /etc/apt/preferences.d/limit-unstable
        elif [ "$DISTRO" == "ubuntu" ]; then
          apt-get remove --purge wireguard qrencode haveged unbound unbound-host -y
          if pgrep systemd-journal; then
            systemctl enable systemd-resolved
            systemctl restart systemd-resolved
          else
            service systemd-resolved enable
            service systemd-resolved restart
          fi
        elif [ "$DISTRO" == "raspbian" ]; then
          apt-key del 04EE7237B7D453EC
          apt-get remove --purge wireguard qrencode haveged unbound unbound-host dirmngr -y
          rm -f /etc/apt/sources.list.d/unstable.list
          rm -f /etc/apt/preferences.d/limit-unstable
        elif [ "$DISTRO" == "arch" ]; then
          pacman -Rs wireguard qrencode haveged unbound unbound-host -y
        elif [ "$DISTRO" == "fedora" ]; then
          dnf remove wireguard qrencode haveged unbound -y
          rm -f /etc/yum.repos.d/wireguard.repo
        elif [ "$DISTRO" == "rhel" ]; then
          yum remove wireguard qrencode haveged unbound unbound-host -y
          rm -f /etc/yum.repos.d/wireguard.repo
        fi
        # Removing Wireguard User Config Files
        rm -rf /etc/wireguard/clients
        # Removing Wireguard Files
        rm -rf /etc/wireguard
        # Removing system wireguard config
        rm -f /etc/sysctl.d/wireguard.conf
        # Removing wireguard config
        rm -f /etc/wireguard/$WIREGUARD_PUB_NIC.conf
        # Removing Unbound Config
        rm -f /etc/unbound/unbound.conf
        # Removing Unbound Files
        rm -rf /etc/unbound
        # Allow the modification of the file
        chattr -i /etc/resolv.conf
        # remove resolv.conf
        rm -f /etc/resolv.conf
        # Moving to resolv.conf
        mv /etc/resolv.conf.old /etc/resolv.conf
        # Stop the modification of the file
        chattr +i /etc/resolv.conf
      fi
      ;;
    9) # Update the script
      curl -o /etc/wireguard/wireguard-server.sh https://raw.githubusercontent.com/complexorganizations/wireguard-manager/master/wireguard-server.sh
      chmod +x /etc/wireguard/wireguard-server.sh || exit
      ;;
    esac
  }

  # Running Questions Command
  wireguard-next-questions

fi
