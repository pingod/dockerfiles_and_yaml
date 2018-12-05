**From https://github.com/davidcaste/docker-alpine-tomcat**

### Versions

**Tomcat 9 Version**: `9.0.13`  
**Tomcat 8 Version**: `8.5.35`  
**Tomcat 7 Version**: `7.0.92`  
**JRE9/JDK9 JRE8/JDK8 JRE7/JDK7 Version**: see https://github.com/pingod/dockerfiles_and_yaml/tree/master/oracle-jdk  

### Tags

镜像仓库地址: registry.cn-hangzhou.aliyuncs.com/sourcegarden/tomcat

| Tomcat version | Java version      | tags                                 |
|:---------------|:------------------|:-------------------------------------|
| Tomcat 9       | Oracle Java 9 JDK | `oracle-jdk9tomcat9`                 |
| Tomcat 9       | Oracle Java 8 JDK | `null`                 |
| Tomcat 9       | Oracle Java 7 JDK | `null`                 |
| Tomcat 9       | Oracle Java 9 JRE | `null`                               |
| Tomcat 9       | Oracle Java 8 JRE | `null`                               |
| Tomcat 9       | Oracle Java 7 JRE | `null`                               |
| Tomcat 8       | Oracle Java 9 JDK | `null`                 |
| Tomcat 8       | Oracle Java 8 JDK | `oracle-jdk8tomcat8`                 |
| Tomcat 8       | Oracle Java 7 JDK | `null`                 |
| Tomcat 8       | Oracle Java 9 JRE | `null`                               |
| Tomcat 8       | Oracle Java 8 JRE | `null`                               |
| Tomcat 8       | Oracle Java 7 JRE | `null`                               |
| Tomcat 7       | Oracle Java 9 JDK | `null`                 |
| Tomcat 7       | Oracle Java 8 JDK | `oracle-jdk8tomcat7`                 |
| Tomcat 7       | Oracle Java 7 JDK | `null`                 |
| Tomcat 7       | Oracle Java 9 JRE | `null`                               |
| Tomcat 7       | Oracle Java 8 JRE | `null`                               |
| Tomcat 7       | Oracle Java 7 JRE | `null`                               |

### Quick start

  ```
  docker run -it --rm registry.cn-hangzhou.aliyuncs.com/sourcegarden/tomcat:oracle-jdk7tomcat7 /opt/tomcat/bin/catalina.sh run
  docker cp ./sample.war tomcat-ci:/opt/tomcat/webapps/sample.war
  ```


### 说明

Some indications:

* 可以进入到目录template下，运行generate.sh脚本来生成对应的dockerfile。如果你打算在我的dockerfile基础上，创建属于自己的dockerfile，那么修改模板文件Dockerfile.tpl即可
* Tomcat installation directory is `/opt/tomcat` (`$TOMCAT_HOME`/`$CATALINA_HOME`). Executable scripts are found in directory `$TOMCAT_HOME/bin` and the application base (*appBase*) directory is `$TOMCAT_HOME/webapps`.
* The path of file `catalina.out` is managed by the variable `$CATALINA_OUT`, and its value by default is `/dev/null` (disabled).
* Apache logs are written into directory `/logs/`.

## Build

build.sh 脚本为构建镜像脚本，需要为此脚本传递3个参数：
1. 脚本执行的动作,脚本支持以下指令：
- **all**: alias to 'build'
- **clean**: remove all container which depends on this image, and remove image previously builded
- **build**: clean and build the current version
- **tag_latest**: tag current version with ":latest"
- **release**: build and execute tag_latest, push image onto registry, and tag git repository
- **debug**: launch an interactive shell using this image
- **run**: run image as daemon and print IP address.
- **save**: export docker image as a tar.gz file


2. 第二个变量为dockerfile文件路径

3. 镜像的tag

例如： ./build.sh release tomcat7/Dockerfile.oracle-jdk-7 oracle-jdk7tomcat7


See [Docker Project Tree](https://github.com/airdock-io/docker-base/wiki/Docker-Project-Tree) for more details.