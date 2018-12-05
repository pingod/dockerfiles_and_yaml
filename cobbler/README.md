# Cobbler 批量装机

> 这是一个运行在docker里的cobbler平台。

### 文件说明

构建cobbler镜像的Dockerfile文件：

- Dockerfile
- start.sh

运行cobbler容器的compose文件：

- docker-compose.yml
- cobbler.env

安装操作系统的kickstart文件:
- centos7-mini.cfg
  - 如果你的iso镜像为最小镜像则使用此kickstart文件,root密码为password
- centos7-dvd.cfg
  - 如果你的iso镜像为dvd镜像则使用此kickstart文件,root密码为password

### 使用说明

1. 首先更改`cobbler.env`变量文件里的变量信息  
2. 把系统镜像挂载到本机的`/mnt`目录下  
3. 运行cobbler容器：`docker-compose up -d`  
4. 进入cobbler容器，配置装机系统：`docker exec -it docker-cobbler_cobbler_1 bash`
5. 由于上面已经将镜像挂载到容器的/mnt下,那么下面将导入到cobbler中: 
  ` cobbler import --path=/mnt/ --name=CentOS-7-x86_64 --arch=x86_64 `
6. 使用cobbler profile list 查看是否有刚才导入的镜像名称
7. 查看配置信息 ` cobbler profile report `
8. 接下来查看/var/lib/cobbler/kickstarts/ 路径下的文件,修改安装操作系统将要使用的kickstart文件路径:
  ` cobbler profile edit --name=CentOS-7-x86_64 --kickstart=/var/lib/cobbler/kickstarts/centos7-mini.cfg `
9. 启动新建的虚拟机,配置启动顺序为pxe
10. 如果新建虚拟机操作系统安装成功并且没有问题,那么接下需要调整cobbler中profile的顺序.编辑/var/lib/tftpboot/pxelinux.cfg/default,调整LABEL标签.
    当然如果你也可修改TIMEOUT超时时间来缩短等待时间
```
DEFAULT menu
PROMPT 0
MENU TITLE Cobbler | http://cobbler.github.io/
TIMEOUT 30
TOTALTIMEOUT 60
ONTIMEOUT CentOS-7-x86_64

LABEL CentOS-7-x86_64
        kernel /images/CentOS-7-x86_64/vmlinuz
        MENU LABEL CentOS-7-x86_64
        append initrd=/images/CentOS-7-x86_64/initrd.img ksdevice=bootif lang=  kssendmac text  ks=http://10.0.100.2/cblr/svc/op/ks/profile/CentOS-7-x86_64
        ipappend 2

MENU end
```


参考连接: 

http://www.jixuege.com/blog/2016/09/20/cobbler-install/

http://blog.51cto.com/jzzone/1154591


