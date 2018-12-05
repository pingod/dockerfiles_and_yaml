**From https://github.com/airdock-io/docker-oracle-jdk**

Docker Image for Oracle Java SDK (JDK and JRE) based on airdock/base:jessie

**Dependency**: airdock/base:jessie


## 说明

1. 目录 template 中有一个 generate.sh 的shell脚本，此脚本用来生成不同版本的jdk/jre的dockerfile文件(目前脚本还是使用的原作者的，以后有时间再改)

2. Java 的二进制文件路径及相关环境变量为 /srv/java

3. 如果官网的JDK下载地址变了，可以去 https://www.oracle.com/technetwork/java/archive-139210.html 查找最新的下载地址，并且替换掉dockerfile中的地址

4. 由于JDK 7去官网下载需要登录Oracle账号，因此我将其上传到我的阿里云服务器上，构建JDK 7的时候会去我的服务器上去拉取包（下载地址需要账号密码，所以如果你打算自己构建，那么需要自己提供JDK的包下载地址）

5. makefile 中镜像仓库的地址为阿里云的镜像仓库地址：registry.cn-hangzhou.aliyuncs.com，所以如果你要使用makefile提供的release功能，那么需要先在阿里云镜像中创建并登录账号，才能开始推送


## Version
**JRE9:null**
**JRE8:null**
**JRE7:null**

**JDK9:9.0.4**
**JDK8:8u191**
**JDK7:7u80**

### Tags

镜像仓库地址: registry.cn-hangzhou.aliyuncs.com/sourcegarden/jdk

| jdk version    | Java version      | tags                                 |
|:---------------|:------------------|:-------------------------------------|
| jdk 9          | Oracle Java 9 JDK | `oracle-jdk-9`                       |
| jdk 8          | Oracle Java 8 JDK | `oracle-jdk-8`                       |
| jdk 7          | Oracle Java 7 JDK | `oracle-jdk-7`                       |

## Quick start

使用已经打包好的镜像

	'docker run --rm -t -i  registry.cn-hangzhou.aliyuncs.com/sourcegarden/jdk:oracle-jdk-7 java -version'

Please note that a correct docker command should be something like this one (using java user defined):

```
 CMD [ "gosu", "java:java", "/srv/java/jvm/bin/java", ... ]
```

JVM uses only 1/4 of system memory by default, with script java-dynamic-memory-opts,
you could set a specific percent of memory (80 % per default) :

```
 CMD [ "gosu", "java:java", "/srv/java/jvm/bin/java", "$(/srv/java/java-dynamic-memory-opts)", ... ]
 or
 CMD [ "gosu", "java:java", "/srv/java/jvm/bin/java", "$(/srv/java/java-dynamic-memory-opts 90)", ... ]
```
If you using this script take care of your host sizing.


## Build

You should install "make" utility.

Under each project, you could retrieve a Makefile with a set of *tasks*:

- **all**: alias to 'build'
- **clean**: remove all container which depends on this image, and remove image previously builded
- **build**: clean and build the current version
- **tag_latest**: tag current version with ":latest"
- **release**: build and execute tag_latest, push image onto registry, and tag git repository
- **debug**: launch an interactive shell using this image
- **run**: run image as daemon and print IP address.
- **save**: export docker image as a tar.gz file

See [Docker Project Tree](https://github.com/airdock-io/docker-base/wiki/Docker-Project-Tree) for more details.

