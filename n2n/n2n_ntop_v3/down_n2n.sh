#!/bin/bash
set -x 
LOG_INFO() {
  echo -e "\033[0;32m[INFO] $* \033[0m"
}
LOG_ERROR() {
  echo -e "\033[0;31m[ERROR] $* \033[0m"
}
LOG_WARNING() {
  echo -e "\033[0;33m[WARNING] $* \033[0m"
}


### 自动识别系统类型
zctmdc_sel_os() {
    uos=$(uname -s | tr '[A-Z]' '[a-z]')
    case $uos in
    *linux*)
        myos="linux"
        ;;
    *dragonfly*)
        myos="dragonfly"
        ;;
    *freebsd*)
        myos="freebsd"
        ;;
    *openbsd*)
        myos="openbsd"
        ;;
    *netbsd*)
        myos="netbsd"
        ;;
    *darwin*)
        myos="macosx"
        ;;
    *aix*)
        myos="aix"
        ;;
    *solaris* | *sun*)
        myos="solaris"
        ;;
    *haiku*)
        myos="haiku"
        ;;
    *mingw* | *msys*)
        myos="windows"
        ;;
    *android*)
        myos="android"
        ;;
    *)
        LOG_ERROR "识别失败的系统 - $uos"
        exit 1
        ;;
    esac
    LOG_INFO "识别成功的系统 - $myos"
}

### 自动识别CPU架构
zctmdc_sel_cpu() {
    ucpu=$(uname -m | tr '[A-Z]' '[a-z]')
    case $ucpu in
    *i386* | *i486* | *i586* | *i686* | *bepc* | *i86pc*)
        mycpu="i386"
        ;;
    *amd*64* | *x86-64* | *x86_64*)
        mycpu="amd64"
        ;;
    *sparc* | *sun*)
        mycpu="sparc"
        if [ "$myos" = "linux" ]; then
            if [ "$(getconf LONG_BIT)" = "64" ]; then
                mycpu="sparc64"
            elif [ "$(isainfo -b)" = "64" ]; then
                mycpu="sparc64"
            fi
        fi
        ;;
    *ppc64le*)
        mycpu="powerpc64el"
        ;;
    *ppc64*)
        mycpu="powerpc64"
        ;;
    *power* | *ppc*)
        if [ "$myos" = "freebsd" ]; then
            mycpu="$(uname -p)"
        else
            mycpu="powerpc"
        fi
        ;;
    *ia64*)
        mycpu="ia64"
        ;;
    *m68k*)
        mycpu="m68k"
        ;;
    *mips*)
        case $ucpu in
        mips | mipsel | mips64 | mips64el)
            mycpu=$ucpu
            ;;
        *)
            LOG_ERROR "分析失败的CPU架构类型 - 未知的 MIPS : $ucpu"
            exit 1
            ;;
        esac
        ;;
    *alpha*)
        mycpu="alpha"
        ;;
    *arm* | *armv6l* | *armv71*)
        mycpu="arm"
        ;;
    *aarch64*)
        mycpu="arm64"
        ;;
    *riscv64*)
        mycpu="riscv64"
        ;;
    *)
        LOG_ERROR "分析失败的CPU架构类型 - $ucpu"
        exit 1
        ;;
    esac
    LOG_INFO "分析成功的CPU架构类型 - $mycpu"
}
myos=""
mycpu=""
zctmdc_sel_os
zctmdc_sel_cpu



if [[ -z ${os_platform_name} ]]; then
    case ${myos} in
    linux)
        os_platform_name="linux"
        ;;
    macosx)
        os_platform_name="darwin"
        ;;
    windows)
        os_platform_name="windows"
        ;;
    *)
        LOG_ERROR "不支持的系统 - ${myos}"
        exit 1
        ;;
    esac
    LOG_INFO "受支持的系统 - ${myos} -> ${os_platform_name}"
fi

if [[ -z ${cpu_arch} ]]; then
    case ${mycpu} in
    i386)
        cpu_arch="x86"
        ;;
    amd64)
        cpu_arch="x64"
        ;;
    arm)
        cpu_arch="arm"
        ;;
    arm64)
        cpu_arch="arm64(aarch64)"
        ;;
    mips | mips64 | mips64el | mipsel | amd64)

        cpu_arch=$mycpu
        ;;
    *)
        LOG_ERROR "不支持的CPU架构类型 - ${mycpu}"
        exit 1
        ;;
    esac
    LOG_INFO "受支持的CPU架构类型 - ${mycpu} -> ${cpu_arch}"
fi

VERSION="_$VERSION"
case $(tr '[A-Z]' '[a-z]' <<<${VERSION##*_}) in
v1)
    SRC_DIR=n2n_v1
    N2N_VERSION=v1
    ;;
v2)
    SRC_DIR=n2n_v2
    N2N_VERSION=v2
    ;;
v2s)
    SRC_DIR=n2n_v2s
    N2N_VERSION=v2s
    ;;
*)
    SRC_DIR=""
    N2N_VERSION=v3
    N2N_FULL_VERSION=v3.1.1-16
    FILE_NAME="https://github.com/lucktu/n2n/raw/master/Linux/n2n_${N2N_VERSION}_linux_${cpu_arch}_${N2N_FULL_VERSION}_r1200_all_by_heiye.rar"
    ;;
esac

LOG_INFO "N2N_VERSION - ${VERSION#*_} -> ${SRC_DIR:+$SRC_DIR:}${N2N_VERSION}"




echo ${FILE_NAME}

if [[ -z ${FILE_NAME} ]]; then
    LOG_ERROR "错误的文件名 - ${FILE_NAME}"
    LOG_ERROR "检查相关变量 - os_platform_name:${os_platform_name}, cpu_arch:${cpu_arch}"
    exit 1
fi


if [[ ! -d /tmp/n2n ]]; then
   mkdir -p /tmp/n2n
fi


wget --no-check-certificate -qO "/tmp/n2n/n2n.rar" ${FILE_NAME}

ls -lh /tmp/n2n

# unzip -o -d /tmp/n2n/ /tmp/n2n.zip 

unrar x /tmp/n2n/n2n.rar /tmp/n2n/
rm /tmp/n2n/n2n.rar

cd  /tmp/n2n/
LOG_INFO "下面将解压/tmp/n2n/目录下最大文件"
file_will_untar=$(ls -lhSr|awk '{print $9}'|tail -n1)
tar -zxvf ${file_will_untar} -C /tmp/n2n/
rm -fr /tmp/n2n/*.tar.gz


chmod +x /tmp/n2n/*

ls -l /tmp/n2n