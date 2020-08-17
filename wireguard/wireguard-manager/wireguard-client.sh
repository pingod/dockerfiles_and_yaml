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
  # System requirements (bc)
  if ! [ -x "$(command -v bc)" ]; then
    echo "Error: bc  is not installed, please install bc." >&2
    exit
  fi
  # System requirements (uname)
  if ! [ -x "$(command -v uname)" ]; then
    echo "Error: uname  is not installed, please install uname." >&2
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
if (( $(echo "$KERNEL_CURRENT_VERSION >= $KERNEL_VERSION_LIMIT" |bc -l) )); then
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

# Install WireGuard Client
function install-wireguard-client() {
  # Installation begins here.
    # shellcheck disable=SC2235
  if [ "$DISTRO" == "ubuntu" ] && ([ "$DISTRO_VERSION" == "20.04" ] || [ "$DISTRO_VERSION" == "19.10" ]); then
    apt-get update
    apt-get install wireguard qrencode haveged resolvconf -y
  fi
  # shellcheck disable=SC2235
  if [ "$DISTRO" == "ubuntu" ] && ([ "$DISTRO_VERSION" == "16.04" ] || [ "$DISTRO_VERSION" == "18.04" ]); then
    apt-get update
    apt-get install software-properties-common -y
    add-apt-repository ppa:wireguard/wireguard -y
    apt-get update
    apt-get install wireguard qrencode haveged resolvconf -y
  fi
  if [ "$DISTRO" == "debian" ]; then
    apt-get update
    echo "deb http://deb.debian.org/debian/ unstable main" >/etc/apt/sources.list.d/unstable.list
    printf 'Package: *\nPin: release a=unstable\nPin-Priority: 90\n' >/etc/apt/preferences.d/limit-unstable
    apt-get update
    apt-get install wireguard qrencode haveged resolvconf -y
  fi
  if [ "$DISTRO" == "raspbian" ]; then
    apt-get update
    apt-get install dirmngr -y
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 04EE7237B7D453EC
    echo "deb http://deb.debian.org/debian/ unstable main" >/etc/apt/sources.list.d/unstable.list
    printf 'Package: *\nPin: release a=unstable\nPin-Priority: 90\n' >/etc/apt/preferences.d/limit-unstable
    apt-get update
    apt-get install wireguard qrencode haveged resolvconf -y
  fi
  if [ "$DISTRO" == "arch" ]; then
    pacman -Syu
    pacman -Syu --noconfirm haveged qrencode iptables
    pacman -Syu --noconfirm wireguard-tools wireguard-arch resolvconf
  fi
  if [ "$DISTRO" = 'fedora' ] && [ "$DISTRO_VERSION" == "32" ]; then
    dnf update -y
    dnf install qrencode wireguard-tools haveged resolvconf -y
  fi
  # shellcheck disable=SC2235
  if [ "$DISTRO" = 'fedora' ] && ([ "$DISTRO_VERSION" == "30" ] || [ "$DISTRO_VERSION" == "31" ]); then
    dnf update -y
    dnf copr enable jdoss/wireguard -y
    dnf install qrencode wireguard-dkms wireguard-tools haveged resolvconf -y
  fi
  if [ "$DISTRO" == "centos" ] && [ "$DISTRO_VERSION" == "8" ]; then
    yum update -y
    yum install epel-release -y
    yum update -y
    yum install resolvconf -y
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
    yum install wireguard-dkms wireguard-tools qrencode haveged resolvconf -y
  fi
  if [ "$DISTRO" == "rhel" ] && [ "$DISTRO_VERSION" == "8" ]; then
    yum update -y
    yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
    yum update -y
    # shellcheck disable=SC2046
    subscription-manager repos --enable codeready-builder-for-rhel-8-$(arch)-rpms
    yum copr enable jdoss/wireguard
    yum install wireguard-dkms wireguard-tools qrencode haveged resolvconf -y
  fi
  if [ "$DISTRO" == "rhel" ] && [ "$DISTRO_VERSION" == "7" ]; then
    yum update -y
    curl https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo --create-dirs -o /etc/yum.repos.d/wireguard.repo
    yum update -y
    yum install epel-release -y
    yum install wireguard-dkms wireguard-tools qrencode haveged resolvconf -y
  fi
}

# WireGuard Client
install-wireguard-client

# Lets check the kernel version and check if headers are required
function install-kernel-headers() {
KERNEL_VERSION_LIMIT=5.6
KERNEL_CURRENT_VERSION=$(uname -r | cut -c1-3)
if (( $(echo "$KERNEL_CURRENT_VERSION <= $KERNEL_VERSION_LIMIT" |bc -l) )); then
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

echo "Move the files to /etc/wireguard/$WIREGUARD_PUB_NIC.conf"

echo "if pgrep systemd-journal; then
      systemctl enable wg-quick@$WIREGUARD_PUB_NIC
      systemctl restart wg-quick@$WIREGUARD_PUB_NIC
    else
      service wg-quick@$WIREGUARD_PUB_NIC enable
      service wg-quick@$WIREGUARD_PUB_NIC restart
    fi"
