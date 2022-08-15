#!/usr/bin/env bash

version=241

main(){
    init
    clean
    build
}

# 初始化操作
init(){
   tar zxvf jre-8u${version}-linux-x64.tar.gz
   cd jre1.8.0_${version}
}


# 删除无用文件
clean(){
    #删除文本文件
    rm -rf COPYRIGHT LICENSE README release THIRDPARTYLICENSEREADME-JAVAFX.txt THIRDPARTYLICENSEREADME.txt Welcome.html \
    #删除其他无用文件
    rm -rf lib/plugin.jar \
    lib/ext/jfxrt.jar \
    bin/javaws \
    lib/javaws.jar \
    lib/desktop \
    plugin \
    lib/deploy* \
    lib/*javafx* \
    lib/*jfx* \
    lib/amd64/libdecora_sse.so \
    lib/amd64/libprism_*.so \
    lib/amd64/libfxplugins.so \
    lib/amd64/libglass.so \
    lib/amd64/libgstreamer-lite.so \
    lib/amd64/libjavafx*.so \
    lib/amd64/libjfx*.so
}

# 重新打包
build(){
 cd ../
 tar -zcvf jre-8u${version}-mini-linux-x64.tar.gz jre1.8.0_${version}
 rm -rf jre1.8.0_${version}
}

main
